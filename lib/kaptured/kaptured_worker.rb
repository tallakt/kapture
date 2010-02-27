require 'active_record'
require 'gphoto4ruby'
require 'fileutils'
require 'image_science'
require 'yaml'

class KaptureWorker
  include ActiveSupport::BufferedLogger::Severity
  include FileUtils

  CAM_FOLDER = 'images/camera/'
  DERIVATIVE_FOLDER = CAM_FOLDER + 'derived/'
  FULLSIZE_FOLDER = CAM_FOLDER + 'fullsize/'
  PREVIEW_FOLDER = CAM_FOLDER + 'preview/'

  attr_accessor :logger

  def run
    begin
      @feedback = WorkerFeedback.first || WorkerFeedback.create
      clear_config
      @logger = nil
      @c = GPhoto2::Camera.new
      WorkerTask.delete_all # start fresh

      initialize_config
      loop do
        while perform_new_tasks do
        end
        feedback :ready
        sleep 0.5
      end
    ensure
      feedback :disconnected
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
    WorkerTask.all.each do |task_record|
      task = YAML::load task_record.task_yaml
      # most primitive security scheme
      send task[:method], *(task[:args] || []) unless Object.respond_to? task[:method]
      task_record.delete
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
    feedback :capture
    perform_capture
  end


  def capture_many
    @stop_capture = false
    continous_capture
  end

  def end_continuous_capture
    @stop_capture = true
  end

  def continuous_capture
      feedback :continuous_capture
      perform_capture
      if not @stop_capture
        new_task = WorkerTask.create :task_yaml => {:method => :continuous_capture }.to_yaml
        new_task.save
      end
  end
  private :continuous_capture


  def bracket_capture
    delta = 2
    raise 'Camera does not exposure compensation' unless @c.config.key? 'exposurecompensation'
    available = @c['exposurecompensation', :all]
    i = available.index @c['exposurecompensation']
    evs = available.values_at [i - delta, i, i + delta]
    raise 'Not possible with available exposures' unless evs.size == 3

    feedback :bracket_capture
    caps.zip(evs).each do |zipped|
      cap, ev = zipped
      @c.merge_config 'exposurecompensation' => ev
      perform_capture cap
    end
    # restore original setting
    @c.merge_config 'exposurecompensation' => ev
  end


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
      mkdir_p Rails.root.join 'public', PREVIEW_FOLDER
      @c.save :type => :preview, :to_folder => (Rails.root.join 'public', PREVIEW_FOLDER).to_s, :new_name => preview_name
      cap.thumbnail = PREVIEW_FOLDER + preview_name
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
        logger.add INFO, '   at: ' + e.backtrace.first
      end
  end
  private :log_exception


  def download(capture_id)
    cap = Capture.find capture_id
    throw 'Invalid capture id' unless cap
    add_task do
      feedback :downloading
      begin
        mkdir_p FULLSIZE_FOLDER
        @c.save :to_folder => FULLSIZE_FOLDER, :name => cap.camera_file, :new_name => cap.camera_file.downcase
        cap.fullsize = folder + cap.camera_file.downcase
        jpeg = nil
        # Convert RAW images to JPEG for viewing in browser
        if not cap.fullsize.match /jpe?g/
          feedback :convert_raw
          mkdir_p DERIVATIVE_FOLDER
          derivative_filename = DERIVATIVE_FOLDER + cap.camera_file.sub(/\..*?$/, 'jpg').downcase
          %x{/usr/bin/dcraw -c -w #{cap.fullsize}| /usr/bin/cjpeg > #{derivative_filename}}
          if File.exists? derivative_filename
            cap.capture_derivatives.create :comment => 'Converted to JPEG from RAW', :filename => derivative_filename
            jpeg = derivative_filename
          end
        else
          jpeg = cap.fullsize
        end

        # Create a medium resolution image for quick download
        if jpeg
          feedback :resizing
          ImageScience.with_image jpeg do |img|
            area = img.width * img.height
            # medium image is 2_000_000 pixels
            factor_medium = Math.sqrt(2_000_000.0 / area)
            img.resize img.width * factor, img.height * factor do |medium|
              med_file = jpeg.sub /\.jpe?g$/, '-medium.jpg'
              medium.save med_file
              cap.capture_derivatives.create :comment => 'Medium size 2Mpix', :filename => med_file

              # Small image is 0.25 megapixel
              factor_small = Math.sqrt(0.25 / 2.0)
              medium.resize medium.width * factor_small, medium.height * factor_small do |small|
                small_file = jpeg.sub /\.jpe?g$/, '-small.jpg'
                small.save small_file
                cap.capture_derivatives.create :comment => 'Small size 0.25Mpix', :filename => small_file
              end
            end
          end
        end
        cap.save
      rescue => e
        log_exception 'Download failed', e
      end
    end
  end


  def cleanup_beagle
    files = []
    CaptureDerivatives.find(:all).each do |cd|
      files << cd.filename
    end
    Captures.find(:all).each do |cap|
      files << cap.filename
    end
    CaptureDerivatives.delete_all # unsafe fast
    Captures.delete_all # unsafe fast
    File.delete files
  end


  def cleanup_camera
    feedback :wipe_camera
    @c.delete :all
  end

  def set_camera_config(config)
    feedback :set_config
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



