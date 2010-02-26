# Mostly copied from http://www.dansketcher.com/2009/04/08/ruby-daemons-and-vendoring/

require 'rubygems'
require 'daemons'
require 'drb'

include ActiveSupport::BufferedLogger::Severity

abort 'Run this daemon using script/runner' unless defined? Rails

FILE_NAME = File.basename(__FILE__) # name to report as the process

# add lib/kaptured to lib path
$:.unshift Rails.root.join 'lib'
require 'kaptured/kaptured_drb'

options = {
             :multiple   => false,
             :ontop      => false,
             :backtrace  => true,
             :log_output => true,
             :monitor    => true
           }

Daemons.run_proc(FILE_NAME, options) do
  # New logger for activerecord and this app, normal log is closed on app exit
  logger = ActiveSupport::BufferedLogger.new Rails.root.join 'log', 'kaptured_%s.log' % RAILS_ENV
  ActiveRecord::Base.logger = logger
  
  logger.add INFO, "Starting #{FILE_NAME} daemon in #{RAILS_ENV} mode"

  loop do
    begin
      kd = KaptureDrb.new
      kd.logger = logger
      begin
        DRb.start_service 'drbunix:///tmp/kaptured', kd
        #DRb.start_service nil, kd
        logger.add INFO, 'DRB URI: ' + DRb.uri
        exceptions = []
        Thread.new {
          begin
            kd.run # loops forever
          rescue e
            exceptions << e
          end
        }.join
        raise exceptions.first if exceptions.any?
        
      ensure
        DRb.stop_service
        DRb.thread.join if DRb.thread
      end
    rescue => e
      logger.add WARN, e.inspect
      logger.add WARN, '   at: ' + e.backtrace.first unless e.message.match 'Unknown model'
      sleep 5
    end
  end
end


