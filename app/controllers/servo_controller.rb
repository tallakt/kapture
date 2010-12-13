class ServoController < ApplicationController
  before_filter :update_feedback, :except => []
  def index
  end

  def tilt_to
      WorkerTask.create :task => {:method => :set_tilt, :args => [amount]}
  end

  def calibration
    redirect_to :action => :edit_servo_pins
  end

  def edit_servo_pins
    @opts = ServoOptions.get
  end

  def post_servo_pins
    ServoOptions.get.update_attributes params['servo_options']
    redirect_to :action => :calibrate_tilt_h
  end

  def calibrate_tilt_h
    if params['offset']
      o = ServoOptions.get
      o.tilt_horizontal = [[o.tilt_horizontal + offset * 2.0, -100.0].max, 100.0].min
      o.save
    end
    WorkerTask.create :task => {:method => :set_tilt, :args => [0.0]}
    respond_to do |format|
      format.html
      format.js { render :none }
    end
  end

  def calibrate_tilt_v
    if params['offset']
      o = ServoOptions.get
      o.tilt_vertical = [[o.tilt_vertical + offset * 2.0, -100.0].max, 100.0].min
      o.save
    end
    WorkerTask.create :task => {:method => :set_tilt, :args => [90.0]}
    respond_to do |format|
      format.html
      format.js { render :none }
    end
  end

  def calibrate_pan_servo
    if params['offset']
      o = ServoOptions.get
      o.rotation_neutral = [[o.rotation_neutral + offset * 2.0, -100.0].max, 100.0].min
      o.save
    end
    WorkerTask.create :task => {:method => :set_pan_speed, :args => [0.0]}
    respond_to do |format|
      format.html
      format.js { render :none }
    end
  end
end



