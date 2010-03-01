require 'gphoto4ruby'
require 'fileutils'
require 'image_science'
require 'yaml'
require 'benchmark'

class KaptureWorker
  include ActiveSupport::BufferedLogger::Severity
  include FileUtils

  CAM_FOLDER = 'camera'
  DERIVATIVE_FOLDER = 'derived'
  FULLSIZE_FOLDER = 'fullsize'
  PREVIEW_FOLDER = 'preview'

  attr_accessor :logger

  def run
    @c = nil
    begin
      @feedback = WorkerFeedback.first || WorkerFeedback.create
      clear_config
      @c = GPhoto2::Camera.new
      WorkerTask.delete_all # start fresh

      initialize_config
      loop do
        while perform_new_tasks do
        end
        @logger.silence do
          feedback :ready
        end
        sleep 0.5
      end
    ensure
      feedback :disconnected
      @c.dispose if @c
    end
  end

  def feedback(m)
    @feedback.status = m.to_s.humanize
    @feedback.gphoto_version = GPhoto2::LIBGPHOTO2_VERSION
    @feedback.model_name = (@c && @c.model_name) || '' 
    @feedback.updated_at_will_change!
    @feedback.save
  end

  def perform_new_tasks
    result = false
    all = nil
    @logger.silence do
      all = WorkerTask.all
    end
    all.each do |task_record|
      task = YAML::load task_record.task_yaml
      # most primitive security scheme
      bm = Benchmark.measure 'Task ' + task[:method].to_s do
        send task[:method], *(task[:args] || []) unless Object.respond_to? task[:method]
      end
      @logger.add INFO, 'Task %s (%.1f)' % [task[:method].to_s, bm.real]
      @logger.silence { task_record.delete }
      result = true
    end
    result
  end
  private :perform_new_tasks

  def clear_config
    CameraAllowedOption.delete_all # unsafe fast
    CameraOption.delete_all # unsafe fast
  end
  private :clear_config

  def initialize_config
    feedback :initializing
    CameraAllowedOption.delete_all # unsafe fast
    CameraOption.delete_all # unsafe fast
    get_fixed_config.each do |k,v|
      co = CameraOption.create :name => k, :value => v, :opt_type => @c[k, :type]
      all = @c[k, :all]
      all.each {|allowed| co.camera_allowed_options.create :value => allowed } unless all.size > 30
    end
  end
  private :initialize_config

  def get_fixed_config
    c = @c.config(:no_cache)
    c.reject! {|k,v| k == 'capture'}
    c
  end
  private :get_fixed_config
  
  # Outside interface

  def capture
    feedback :capturing
    perform_capture
  end


  def capture_many
    @stop_capture = false
    continuous_capture
  end

  def end_capture_many
    @stop_capture = true
  end

  def continuous_capture
      feedback :capturing_repeated
      perform_capture
      if not @stop_capture
        new_task = WorkerTask.create :task_yaml => {:method => :continuous_capture }.to_yaml
        new_task.save
      end
  end
  private :continuous_capture


  def canon_hack_capture
    if @c.config.key? 'capture'
      @c['capture'] = true
    end
    @c.capture
  end
  private :canon_hack_capture

  def perform_capture
    cap = Capture.new
    begin
      canon_hack_capture
      file = @c.files(1).last
      preview_name = file.sub(/\..*?$/, '.JPG').downcase
      mkdir_p preview_f
      @c.save :type => :preview, :to_folder => preview_f.to_s, :new_name => preview_name
      cap.thumbnail = preview_f.join(preview_name).to_s
      cap.camera_file = file
      cap.save
    rescue => e
      cap.destroy
      log_exception 'Capture aborted', e
      raise
    end
  end
  private :perform_capture

  def log_exception(message, e)
      if logger
        logger.add INFO, message
        logger.add INFO, '   ' + e.inspect
        logger.add INFO, '   at: ' + e.backtrace[0..5].join("\n")
      end
  end
  private :log_exception

  def fullsize_f
    Rails.root.join 'public', 'images', CAM_FOLDER, FULLSIZE_FOLDER
  end

  def derivative_f
    Rails.root.join 'public', 'images', CAM_FOLDER, DERIVATIVE_FOLDER
  end

  def preview_f
    Rails.root.join 'public', 'images', CAM_FOLDER, PREVIEW_FOLDER
  end

  def download(capture_id)
    mkdir_p fullsize_f
    mkdir_p derivative_f

    cap = Capture.find capture_id
    throw 'Invalid capture id' unless cap

    feedback :downloading
    begin
      @c.save :to_folder => fullsize_f.to_s, :name => cap.camera_file, :new_name => cap.camera_file.downcase
      cap.fullsize = fullsize_f.join(cap.camera_file.downcase).to_s
      jpeg = nil
      # Convert RAW images to JPEG for viewing in browser
      if not cap.fullsize.match /jpe?g/
        feedback :converting_from_raw_to_jpeg
        derivative_fn = derivative_f.join(cap.camera_file.sub(/\..*?$/, '.jpg').downcase).to_s
        %x{/usr/bin/dcraw -c -w #{cap.fullsize} | /usr/bin/cjpeg -quality 85 > #{derivative_fn}}
        if File.exists? derivative_fn
          cap.capture_derivatives.create :comment => 'Converted to JPEG from RAW', :filename => derivative_fn
          jpeg = derivative_fn
        end
      else
        jpeg = cap.fullsize
      end

      # Create a medium resolution image for quick download
      if jpeg
        feedback :resizing
        ImageScience.with_image jpeg do |img|
          area = img.width * img.height
          # medium image is 2.0 megapixel
          factor_medium = Math.sqrt(2_000_000.0 / area)
          img.resize img.width * factor_medium, img.height * factor_medium do |medium|
            med_file = new_derivative_fn jpeg, 'medium'
            medium.save med_file
            cap.capture_derivatives.create :comment => 'Medium - 2 megapixel', :filename => med_file

            # Small image is 0.25 megapixel
            factor_small = Math.sqrt(0.25 / 2.0)
            medium.resize medium.width * factor_small, medium.height * factor_small do |small|
              small_file = new_derivative_fn jpeg, 'small'
              small.save small_file
              cap.capture_derivatives.create :comment => 'Small - 0.25 megapixel', :filename => small_file
            end
          end
        end
      end
      cap.save
    rescue => e
      log_exception 'Download failed', e
      raise
    end
  end

  def new_derivative_fn(original, filename_addition)
    new_base = File.basename(original).sub /[.]/, "-#{filename_addition}."
    derivative_f.join(new_base).to_s
  end


  def cleanup_beagle
    feedback :cleaning_up_controller
    files = []
    CaptureDerivative.find(:all).each do |cd|
      files << cd.filename
    end
    Capture.find(:all).each do |cap|
      files << cap.fullsize
      files << cap.thumbnail
    end
    CaptureDerivative.delete_all # unsafe fast
    Capture.delete_all # unsafe fast
    files.compact!
    files.each {|f| File.delete f }
  end


  def cleanup_camera
    feedback :deleting_pictures_on_camera
    @c.delete :all
  end

  def set_camera_config(config)
    feedback :setting_config
    @c.config_merge config
    get_fixed_config # force update
    CameraOption.all.each do |co|
      if config.key? co.name
        co.value = @c[co.name]
        co.save
      end
    end
  end
end



