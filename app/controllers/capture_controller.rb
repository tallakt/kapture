class CaptureController < ApplicationController
  before_filter :update_feedback, :except => [:perform_capture]


  def update_new_data
    @new_data = true
    if cookies[:newest]
      cc = Capture.find_by_id @capture.id, :conditions => ['updated_at > ?', cookies[:newest]]
      @new_data = false unless cc
      cookies[:newest] = @capture.updated_at.to_s(:db)
    end
  end

  def index
    @capture = Capture.last_with_preview
    update_new_data 
    respond_to do |format|
      format.html
      format.js
    end
  end

  def list
    @captures = Capture.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @capture = Capture.find params[:id]
    update_new_data
    respond_to do |format|
      format.html
      format.js
    end
  end

  def perform_capture
    WorkerTask.create :task => {:method => :capture}
    render :nothing => true
  end

  def perform_end_capture_many
    WorkerTask.create :task => {:method => :end_capture_many}
    render :nothing => true
  end

  def perform_capture_many
    WorkerTask.create :task => {:method => :capture_many}
    render :nothing => true
  end

  def perform_download
    capture = Capture.find(params[:id])
    raise 'Downloading nonexistent capture' unless capture
    WorkerTask.create :task => {:method => :download, :args => [capture.id]}
    #TODO redirect to browser for that image
    render :nothing => true
  end
end
