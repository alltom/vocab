require 'rake'

coverage_minimum_threshold_path = File.expand_path(RAILS_ROOT + '/config/coverage_minimum_threshold')
constant_threshold = File.exist?(coverage_minimum_threshold_path) ? File.readlines(coverage_minimum_threshold_path).to_s.to_f : 100.0

rspec_base = File.expand_path(RAILS_ROOT + '/vendor/plugins/rspec')

if File.exist?(rspec_base)
  require rspec_base + '/lib/spec/rake/spectask'
  require rspec_base + '/lib/spec/rake/verify_rcov'
else
  require 'spec/rake/spectask'
  require 'spec/rake/verify_rcov'
end

desc "Run all behaviours (excluding Watir/Selenium) in one pass with a required threshold of coverage"
RCov::VerifyTask.new(:cruise => 'cruise:tasks') do |t|
  t.threshold = constant_threshold
  t.require_exact_threshold = false
  t.index_html = 'coverage/index.html'
end

Spec::Rake::SpecTask.new('cruise:tasks' => ["db:migrate", "db:test:prepare", "stories"]) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb'].delete_if { |spec_dir| spec_dir.downcase.include?('watir') }.sort

  if RUBY_PLATFORM.include?('darwin')
    t.spec_opts << ' -cfp'
  else
    t.spec_opts << ' -fp'
  end

  t.rcov_opts << '--rails --no-validator-links --only-uncovered --comments --sort=coverage --exclude=spec/*,/Library/Ruby/*'
  t.rcov = true
end