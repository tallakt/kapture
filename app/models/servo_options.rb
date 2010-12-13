class ServoOptions < ActiveRecord::Base
  def ServoOptions.get
    options = find :first
    if not options
      options = ServoOptions.create
      # uncalibrated defaults
      options.rotation_pin = 19
      options.rotation_rpm = 1.0
      options.rotation_neutral = 0.0
      options.tilt_pin = 21
      options.tilt_horizontal = 100.0
      options.tilt_vertical = -100.0
      options.save
    end
    options
  end
end
