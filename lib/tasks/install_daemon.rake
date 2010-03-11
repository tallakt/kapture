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

  desc 'Install Thin web server - run with sudo'
  task :install_thin do
    mkdir '/etc/thin' unless File.exists? '/etc/thin'
    sh "thin config -c #{RAILS_ROOT} --port 80 -d --environment production --servers 1 -C /etc/thin/kapture.yml " +
        "--max-persistent-conns 32 --max-conns 64 --tag kapture-thin -r rubygems"
    sh 'thin install'
    sh 'update-rc.d thin defaults'
    puts "\n" + 'sudo /etc/init.d/thin start  -- type this to start Thin now'
    puts "\n\nNote: If you are unable to run Thin, make sure you only have Rack v1.0.1 installed"
  end

  desc 'Uninstall Thin'
  task :uninstall_thin do
    rm '/etc/thin/kapture.yml'
    rm '/etc/init.d/thin'
    sh 'update-rc.d thin remove'
  end

  desc 'Install Thin and Kaptured daemons in init.d (use sudo)'
  task :install => [:install_kaptured, :install_thin]

  desc 'Uninstall Thin and Kaptured daemons in init.d (use sudo)'
  task :uninstall => [:uninstall_kaptured, :uninstall_thin]
end
