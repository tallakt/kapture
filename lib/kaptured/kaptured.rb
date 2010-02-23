# Mostly copied from http://www.dansketcher.com/2009/04/08/ruby-daemons-and-vendoring/

require 'rubygems'
require 'daemons'

RAILS_ENV = ARGV[1] || 'development'
require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
FILE_NAME = File.basename(__FILE__) # name to report as the process
puts "Starting #{FILE_NAME} daemon in #{RAILS_ENV} mode"

# add lib/kaptured to lib path
$:.unshift File.dirname(__FILE__)
require 'kaptured_drb'

options = {
             :multiple   => false,
             :ontop      => false,
             :backtrace  => true,
             :log_output => true,
             :monitor    => true
           }

Daemons.run_proc(FILE_NAME, options) do
  loop do
    begin
      kd = KaptureDrb.new
      begin
        DRB.start_service 'drbunix://127.0.0.1:8787', kd
        puts 'DRb URI: ' + DRb.uri
        kd.run # loops forever
      ensure
        DRB.stop_service
        DRB.thread.join
      end
    rescue => e
      puts e.inspect
      sleep 5
    end
  end
end


