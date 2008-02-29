desc "Run the following task(s) in the TEST environment [ec]"

namespace :app do

  desc "Runs the application.  Step 1: svn up, Step 2: rake db:migrate, Step 3: script/server"
  task :run do
    puts ""
    puts "===== Updating application from subversion ====="
    sh("svn up #{RAILS_ROOT}")
    puts "================================================"
    puts ""
    
    puts "===== Migrating the application database ====="
    Rake::Task['db:migrate'].invoke
    puts "================================================"
    puts ""
    
    puts "===== Starting the application server =====" 
    sh("#{RAILS_ROOT}/script/server")
    puts "================================================"
    puts ""
  end

end