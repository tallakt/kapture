class CameraController < ApplicationController
  before_filter :update_feedback, :except => [:capture]

  def index
    @preview = Capture.last_with_preview
  end


  def capture
    WorkerTask.create :task_yaml => {:method => :capture}.to_yaml
    render :nothing => true
  end

  def update # AJAX
    @preview = Capture.last_with_preview

    respond_to do |format|
      format.js # update.rjs
    end
  end
end
