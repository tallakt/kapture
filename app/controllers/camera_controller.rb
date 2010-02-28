class CameraController < ApplicationController
  before_filter :update_feedback, :except => [:perform_capture]

  def index
  end


  def perform_capture
    WorkerTask.create :task_yaml => {:method => :capture}.to_yaml
    render :nothing => true
  end

  def perform_end_capture_many
    WorkerTask.create :task_yaml => {:method => :end_capture_many}.to_yaml
    render :nothing => true
  end

  def perform_capture_many
    WorkerTask.create :task_yaml => {:method => :capture_many}.to_yaml
    render :nothing => true
  end

  def update # AJAX
    @preview = Capture.last_with_preview

    respond_to do |format|
      format.js # update.rjs
    end
  end

  def capture
    @preview = Capture.last_with_preview
  end
end
