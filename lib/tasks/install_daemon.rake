namespace 'daemon' do

  def copy_file_with_replace(from, to, search, replace)
    File.open to, 'w' do |output|
      File.open from do |input|
        input.each_line do |l|
          l.gsub! search, replace
          output.puts l
        end
      end
    end
  end

  # KAPTURED
  INIT_D_FILE_KAPTURED = '/etc/init.d/kaptured'
  INIT_D_SOURCE_KAPTURED = 'lib/init.d/kaptured'

  desc 'Install kapture daemon in init.d (run with sudo)'
  task :install_kaptured do
    puts "Copying startup script file to #{INIT_D_FILE_KAPTURED}"
    puts "Setting RAILS_ROOT=#{RAILS_ROOT} in the new file"
    copy_file_with_replace INIT_D_SOURCE_KAPTURED, INIT_D_FILE_KAPTURED, /^RAILS_ROOT.?=.*/, 'RAILS_ROOT="%s"' % RAILS_ROOT
    puts 'Change mode to executable'
    sh "chmod +x #{INIT_D_FILE_KAPTURED}"
    cmd = 'update-rc.d kaptured defaults'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end

  desc 'Uninstall kapture'
  task :uninstall_kaptured do
    puts "Deleting #{INIT_D_FILE_KAPTURED}"
    sh "rm #{INIT_D_FILE_KAPTURED}"
    cmd = 'update-rc.d kaptured remove'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end

  # MONGREL
  INIT_D_FILE_MONGREL = '/etc/init.d/mongrel'
  INIT_D_SOURCE_MONGREL = 'lib/init.d/mongrel'

  desc 'Install mongrel daemon in init.d (run with sudo)'
  task :install_mongrel do
    puts "Copying startup script file to #{INIT_D_FILE_MONGREL}"
    puts "Setting RAILS_ROOT=#{RAILS_ROOT} in the new file"
    copy_file_with_replace INIT_D_SOURCE_MONGREL, INIT_D_FILE_MONGREL, /^RAILS_ROOT.=?.*/, 'RAILS_ROOT="%s"' % RAILS_ROOT
    puts 'Change mode to executable'
    sh "chmod +x #{INIT_D_FILE_MONGREL}"
    cmd = 'update-rc.d mongrel defaults'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end

  desc 'Uninstall mongrel'
  task :uninstall_mongrel do
    puts "Deleting #{INIT_D_FILE_MONGREL}"
    sh "rm #{INIT_D_FILE_MONGREL}"
    cmd = 'update-rc.d mongrel remove'
    puts 'Running: ' + cmd
    sh cmd
    puts "done."
  end

  desc 'Install mongrel and kaptured daemons in init.d (use sudo)'
  task :install => [:install_kaptured, :install_mongrel]

  desc 'Uninstall mongrel and kaptured daemons in init.d (use sudo)'
  task :uninstall => [:uninstall_kaptured, :uninstall_mongrel]
end
