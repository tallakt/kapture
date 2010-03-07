class ConfigController < ApplicationController
  before_filter :update_feedback, :except => [:select_option]

  def index
    cookies[:newest] = CameraOption.newest_updated_at_db
    @options = CameraOption.find :all, :order => :name
  end

  def select_option 
    ao = CameraAllowedOption.find(params[:id])
    logger.info 'select option, value: %s' % ao.value
    WorkerTask.create :task => {:method => :set_camera_config, :args => [{ao.camera_option.name => ao.value}]}
    render :nothing => true
  end

  def update
    since = cookies[:newest] || 1.month.ago
    cookies[:newest] = CameraOption.newest_updated_at_db
    @options = CameraOption.find :all, :conditions => ['updated_at > ?', since]

    @options.each do |o|
      logger.info 'Detected changed option: ' + o.inspect
    end

    respond_to do |format|
      format.js # update.rjs
    end
  end



end
