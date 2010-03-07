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
    WorkerTask.create :task => {:method => :cleanup_camera}
    redirect_to :action => :index
  end

  def cleanup_beagle
    WorkerTask.create :task => {:method => :cleanup_beagle}
    redirect_to :action => :index
  end
end
