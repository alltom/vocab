desc "Run the following task(s) in the TEST environment [ec]"
task :testing do
  RAILS_ENV = ENV['RAILS_ENV'] = 'test'
end

desc "Run the following task(s) in the DEVELOPMENT environment [ec]"
task :dev do
  RAILS_ENV = ENV['RAILS_ENV'] = 'development'
end

desc "Run the following task(s) in the PRODUCTION environment [ec]"
task :prod do
  RAILS_ENV = ENV['RAILS_ENV'] = 'production'
end