# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def update_feedback
    @f = WorkerFeedback.first
    @mode = @f.status || '???'
    @mode_update_time = @f.updated_at
    @camera_model = @f.model_name || '???'
    @gphoto_version = @f.gphoto_version || '???'
  end
end
