class CameraConfigController < ApplicationController
  before_filter :update_mode, :except => [:select_option]

  def index
    @options = CameraOption.find :all, :order => :name
    @version = get_kaptured_drb.gphoto_version rescue ''
    @model_name = get_kaptured_drb.camera_model_name rescue ''
  end

  def select_option
    ao = CameraAllowedOption.find(params[:id])
    logger.info 'select option, value: %s' % ao.value
    get_kaptured_d:tbrb.set_camera_config ao.camera_option.name => ao.value
    CameraOption.uncached { ao.camera_option.reload }
    render :partial => 'single_option_table_row', :locals => {:o => ao.camera_option }
  end



end
