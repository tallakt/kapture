class CaptureController < ApplicationController
  before_filter :update_feedback, :except => [:perform_capture]

  def index
    @capture = Capture.last_with_preview
    respond_to do |format|
      format.html
      format.js
    end
  end

  def list
    @captures = Capture.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    puts @captures.inspect
    respond_to do |format|
      format.html
      format.js
    end
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

  def perform_download
    capture = Capture.find(params[:id])
    raise 'Downloading nonexistent capture' unless capture
    WorkerTask.create :task_yaml => {:method => :download, :args => [capture.id]}.to_yaml
    #TODO redirect to browser for that image
    render :nothing => true
  end
end
