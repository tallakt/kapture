class CameraConfigController < ApplicationController
  before_filter :update_mode, :except => [:select_option]

  def index
    @mode = get_kaptured_drb.mode
    @options = CameraOption.find :all, :order => :name
    @version = get_kaptured_drb.gphoto_version
    @abilities = get_kaptured_drb.camera_abilities
  end

  def select_option
    ao = CameraAllowedOption.find(params[:id])
    logger.info 'select option, value: %s' % ao.value
    get_kaptured_d:tbrb.set_camera_config ao.camera_option.name => ao.value
    CameraOption.uncached { ao.camera_option.reload }
    render :partial => 'single_option_table_row', :locals => {:o => ao.camera_option }
  end



end
