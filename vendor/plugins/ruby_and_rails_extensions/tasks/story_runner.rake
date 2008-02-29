
desc "Runs the application.  Step 1: svn up, Step 2: rake db:migrate, Step 3: script/server"
task :stories do
  puts "Running all stories"
  sh("ruby #{RAILS_ROOT}/stories/all.rb")
end

namespace :stories do
  desc "Run the stories with Rcov"
  task :rcov do
    sh("rcov --comment --no-validator-links --rails --exclude=db/*,lib/*,config/*,spec/*,stories/*,/Library/Ruby/* #{RAILS_ROOT}/stories/all.rb")
    puts "Open coverage/index.html to view coverage statistics"
  end
end