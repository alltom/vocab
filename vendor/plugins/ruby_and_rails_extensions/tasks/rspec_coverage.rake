require 'rake'
require 'find'

rspec_base = File.expand_path(RAILS_ROOT + '/vendor/plugins/rspec')

if File.exist?(rspec_base)
  require rspec_base + '/lib/spec/rake/spectask'
else
  require 'spec/rake/spectask'
end

namespace :app do
  desc "Generate a RCov report for all classes (except watir/selenium) covered by RSpec"
  Spec::Rake::SpecTask.new(:coverage => 'db:test:prepare') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb'].delete_if { |spec_dir| spec_dir.downcase.include?('watir') }
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.rcov = true
    t.rcov_opts << '--comment --no-validator-links --rails --exclude=db/*,lib/*,config/*,spec/*,/Library/Ruby/*'
  end
  
  namespace :coverage do
 
    desc "Run a specific coverage scenario ensuring it meets a 90% code coverage threshold"
    task :scenarios do |t|
      if ENV['FILE'].nil?
        puts "Please provide a FILE to run via FILE=scenario_name.  We will look for these files in spec/coverage_scenarios/"
        exit
      end

      scenario_yml = YAML.load_file(File.expand_path("#{RAILS_ROOT}/spec/coverage_scenarios/#{ENV['FILE']}.yml"))
      scenario = scenario_yml['scenario']

      Spec::Rake::SpecTask.new(scenario_yml['scenario_yml'] => 'db:test:prepare') do |t|
        t.spec_files = scenario
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.rcov = true
        t.rcov_opts << "--comment --no-validator-links --rails --threshold=90 --sort coverage --exclude=db/*,lib/*,config/*,spec/*,/Library/Ruby/*"
      end
      
      puts ''
      puts "=== Running scenario #{ENV['FILE'].capitalize} ==="
      Rake::Task[scenario_yml['scenario_yml']].invoke
    end
 
    entity_types = [:models, :controllers, :helpers, :views]
    entity_types.each do |spec_entity| 
      desc "Generate a RCov report for all #{spec_entity} classes (except watir/selenium) covered by RSpec"
      Spec::Rake::SpecTask.new(spec_entity => 'db:test:prepare') do |t|
        spec_files = FileList["spec/#{spec_entity}/*_spec.rb"].delete_if { |spec_dir| spec_dir.downcase.include?('watir') }
        other_entities = entity_types.dup.delete_if { |e| e == spec_entity }
        exclude_list = []
        other_entities.each do |other_entity_type|
          exclude_list << "app/#{other_entity_type}/*"
        end

        t.spec_files = spec_files
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.rcov = true
        t.rcov_opts << '--comment --no-validator-links --sort coverage --rails --exclude=db/*,lib/*,/Library/Ruby/*,config/*,spec/*,' + exclude_list.join(',')
      end
    end

    desc "Generate a RCov report for all classes that are below 70% covered by RSpec"
    Spec::Rake::SpecTask.new(:needed => 'db:test:prepare') do |t|
      t.spec_files = FileList['spec/**/*_spec.rb'].delete_if { |spec_dir| spec_dir.downcase.include?('watir') }
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.rcov = true
      t.rcov_opts << '--comment --no-validator-links --rails --threshold=70 --sort coverage --exclude=db/*,lib/*,config/*,spec/*,/Library/Ruby/*'
    end
    
  end
end