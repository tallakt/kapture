namespace 'daemon' do

  INIT_D_FILE = '/etc/init.d/kaptured'
  INIT_D_SOURCE = 'lib/kaptured/init.d/kaptured'

  desc 'Install kapture dameon in init.d (run with sudo)'
  task :install do
    puts "Copying startup script file to #{INIT_D_FILE}"
    puts "Setting RAILS_ROOT=#{RAILS_ROOT} in the new file"
    File.open INIT_D_FILE, 'w' do |output|
      File.open INIT_D_SOURCE do |input|
        input.each_line do |l|
          l.gsub! /RAILS_ROOT=.*/, 'RAILS_ROOT="%s"' % RAILS_ROOT
          output.puts l
        end
      end
    end
    puts 'Change mode to executable'
    sh "chmod +x #{INIT_D_FILE}"
    cmd = 'update-rc.d kaptured defaults'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end

  desc 'Install kapture dameon in init.d (run with sudo)'
  task :uninstall do
    puts "Deleting #{INIT_D_FILE}"
    sh "rm #{INIT_D_FILE}"
    cmd = 'update-rc.d kaptured remove'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end
end
