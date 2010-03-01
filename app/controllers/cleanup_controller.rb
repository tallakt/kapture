class CleanupController < ApplicationController
  def index
    update_feedback
    @count = Capture.count
    respond_to do |format|
      format.html
      format.js
    end
  end

  def cleanup_camera
    WorkerTask.create :task_yaml => {:method => :cleanup_camera}.to_yaml
    redirect_to :action => :index
  end

  def cleanup_beagle
    WorkerTask.create :task_yaml => {:method => :cleanup_beagle}.to_yaml
    redirect_to :action => :index
  end
end
