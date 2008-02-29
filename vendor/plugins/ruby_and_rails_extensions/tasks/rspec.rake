require 'rake'
require 'find'

rspec_base = File.expand_path(RAILS_ROOT + '/vendor/plugins/rspec')

if File.exist?(rspec_base)
  require rspec_base + '/lib/spec/rake/spectask'
else
  require 'spec/rake/spectask'
end

namespace :app do
  
  desc "Run all behaviors (excluding Watir/Selenium) in one pass"
  Spec::Rake::SpecTask.new(:spec => 'db:test:prepare') do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb'].delete_if { |spec_dir| spec_dir.downcase.include?('watir') }.sort
  end
  
end

task :default => 'app:spec'

namespace :db do
   namespace :fixtures do
     desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
     task :load => :environment do
       require 'active_record/fixtures'
       ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

       fixtures = (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', '*.{yml,csv}')))

       fixtures.sort.reverse.each do |fixture_file|
         puts "Loading fixture file from #{fixture_file.split('..').last}..." unless fixture_file.nil?
         Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
       end
     end
   end
 end