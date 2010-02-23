require 'activerecord'
require 'drb'
require 'gphoto4ruby'
require 'fileutils'
require 'image_science'

require 'worker_queue'

class KaptureDrb
  CAM_FOLDER = Rails.root.join 'public/cam_images/'
  DERIVATIVE_FOLDER = CAM_FOLDER + 'derived/'
  FULLSIZE_FOLDER = CAM_FOLDER + 'fullsize/'
  PREVIEW_FOLDER = CAM_FOLDER + 'preview/'

  attr_reader :mode

  def initialize
      @c = GPhoto2::Camera.new
      @canon_hack = {}
      @canon_hack['capture'] = true if @c.get_config[:no_cache].key?('capture')
      @tasks = WorkerQueue.new { @mode = :ready }
      add_task { initalize_config }
  end

  def run
    @tasks.run
  end

  def add_task(&block) 
    @tasks << block
  end

  def initialize_config
    CameraAllowedOption.delete_all # unsafe fast
    CameraOption.delete_all # unsafe fast
    get_fixed_config.each do |k,v|
      co = CameraOption.new
      co.name, co.value = k, v
      co.type = @c[k, :type]
      @c[type, :all].each {|allowed| co.create_camera_allowed_option :value => allowed }
      co.save!
    end
  end

  def get_fixed_config
    @c.get_config[:no_cache].reject! {|k,v| k == 'capture'}
  end
  
  # Outside interface

  def capture
    cap = Capture.new
    cap.save
    add_task do
      @mode = :capture
      perform_capture
    end
    cap.id
  end


  def capture_many(sleep_time = 0)
    add_task do 
      @mode = :continuous_capture
      while @mode == :continuous_capture do
        perform_capture
        sleep sleep_time
      end
    end
  end


  def bracket_capture(delta = 2)
    raise 'Camera does not support bracketing' unless @c.get_config.key? 'EV'
    available = @c['EV', :all]
    i = available.index @c['EV']
    evs = available.values_at [i - delta, i, i + delta]
    raise 'Not possible with available exposures' unless evs.size == 3

    caps = (0..2).map { Capture.new }
    caps.each {|c| c.save }
    add_task do 
      @mode = :bracket_capture
      caps.zip(evs).each do |zipped|
        cap, ev = zipped
        @c.merge_config 'EV' => ev
        perform_capture cap
      end
      # restore original setting
      @c.merge_config 'EV' => ev
    end
    caps.map {|c| c.id }
  end


  def end_continuous_capture
    @mode = :end_continous_capture
  end


  def perform_capture(cap = Capture.new)
    begin
      @c.capture opts + @canon_hack
      file = @c.files(1).last
      preview_name = PREVIEW_FOLDER + file.sub(/\..*?$/, '.JPEG').downcase
      mkdir_p PREVIEW_FOLDER
      @c.save :type => :preview, :to_folder => folder, :new_name => preview_name
      cap.preview = folder + preview_name
      cap.camera_file = file
      cap.save
    rescue
      cap.destroy
    end
  end
  private :perform_capture

  def download(capture_id)
    cap = Capture.find capture_id
    throw 'Invalid capture id' unless cap
    add_task do
      @mode = :downloading
      begin
        mkdir_p FULLSIZE_FOLDER
        @c.save :to_folder => folder, :name => cap.camera_file, :new_name => cap.camera_file.downcase
        cap.fullsize = folder + cap.camera_file.downcase
        jpeg = nil
        # Convert RAW images to JPEG for viewing in browser
        if not cap.fullsize.match /jpe?g/
          @mode = :convert_raw
          mkdir_p DERIVATIVE_FOLDER
          derivative_filename = DERIVATIVE_FOLDER + cap.camera_file.sub(/\..*?$/, 'jpeg').downcase
          %x{/usr/bin/dcraw -c -w #{cap.fullsize}| /usr/bin/cjpeg > #{derivative_filename}}
          if File.exists? derivative_filename
            cap.create_capture_derivative :comment => 'Converted to JPEG from RAW', :filename => derivative_filename
            jpeg = derivative_filename
          end
        else
          jpeg = cap.fullsize
        end

        # Create a medium resolution image for quick download
        if jpeg
          @mode = :resizing
          ImageScience.with_image jpeg do |img|
            area = img.width * img.height
            # medium image is 2_000_000 pixels
            factor_medium = Math.sqrt(2_000_000.0 / area)
            img.resize img.width * factor, img.height * factor do |medium|
              med_file = jpeg.sub /\.jpe?g$/, '-medium.jpeg'
              medium.save med_file
              cap.create_capture_derivative :comment => 'Medium size 2Mpix', :filename => med_file

              # Small image is 0.25 megapixel
              factor_small = Math.sqrt(0.25 / 2.0)
              medium.resize medium.width * factor_small, medium.height * factor_small do |small|
                small_file = jpeg.sub /\.jpe?g$/, '-small.jpeg'
                small.save small_file
                cap.create_capture_derivative :comment => 'Small size 0.25Mpix', :filename => small_file
              end
            end
          end
        end
        cap.save
      rescue => e
        $stderr.puts e.inspect
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
    add_task do
      @mode = :wipe_camera
      @c.delete :all
    end
  end


  def set_camera_config(config)
    @c.merge_config config
    initialize_config
  end
end



