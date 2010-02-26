class CameraConfigController < ApplicationController
  before_filter :update_feedback

  def index
    @options = CameraOption.find :all, :order => :name
  end

  def select_option # AJAX
    ao = CameraAllowedOption.find(params[:id])
    logger.info 'select option, value: %s' % ao.value
    WorkerTask.create :task_yaml => {:method => set_camera_config, :args => [{ao.camera_option.name => ao.value}]}.to_yaml
#    CameraOption.uncached { ao.camera_option.reload }
#    render :partial => 'single_option_table_row', :locals => {:o => ao.camera_option }
  end



end
