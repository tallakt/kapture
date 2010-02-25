class CameraController < ApplicationController
  before_filter :update_mode, :except => [:capture]

  def index
    @preview = Capture.last
  end


  def capture
    get_kaptured_drb.capture
    render :nothing => true
  end

  def update
    @preview = Capture.last

    respond_to do |format|
      format.js # update.rjs
    end
  end
end
