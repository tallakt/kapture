# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  @@kaptured_drb = nil

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def get_kaptured_drb
    if not @@kaptured_drb
      DRb.start_service
      @@kaptured_drb = DRbObject.new nil, 'drbunix:///tmp/kaptured'
    end 
    @@kaptured_drb
  end


  def update_mode
    begin
      @mode = get_kaptured_drb.mode.to_s.gsub(/_/, ' ').capitalize
    rescue DRb::DRbConnError
      @mode = 'No connection'
    end
  end
end
