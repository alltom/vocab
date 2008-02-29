# Originally from http://trac.underpantsgnome.com/plugins/wiki, but changed with several locally needed modifications
require 'rubygems'
require 'yaml'
require 'erb'
require 'fileutils'


class GemTools
  class << self
    def require_gems
      config = self.load_gem_configuration

      unless config['gems'].nil?
        gems = config['gems'].reject {|gem_info| ! gem_info['load_after_require'] }
        gems.each do |gem_info|
          puts "** Requiring gem #{gem_info['name']}"
          if defined?(Kernel::gem)
            if gem_info['version'].nil?
              gem gem_info['name']
            else
              gem gem_info['name'], gem_info['version']
            end
          else
            if gem_info['version'].nil?
              require_gem gem_info['name']
            else
              require_gem gem_info['name'], gem_info['version'].to_s
            end
          end
          
          require (gem_info['require_name'] || gem_info['name'])
        end
      end

      standard_dirs = ['rails', 'plugins']
      gems = Dir[File.join(RAILS_ROOT, "vendor/gems/**")]

      if gems.any?
        gems.each do |dir|
          next if standard_dirs.include?(File.basename(dir))
          lib = File.join(dir, 'lib')
          puts "** Adding [vendor/gems/#{File.basename(dir)}] to load path" if RAILS_ENV == 'development'
          $LOAD_PATH.unshift(lib) if File.directory?(lib)
        end
      end
    end
  
    def load_gem_configuration
      config_file = File.join(RAILS_ROOT, 'config', 'gems.yml')
      
      unless File.exists?(config_file)
        copy_default_configuration
        puts 'Default gems.yml has been copied to config.  Please edit it prior to re-running this command.'
        puts 'You must also add the following line after the boot.rb include in your environment.rb'
        puts 'require File.expand_path("#{RAILS_ROOT}/vendor/plugins/ruby_and_rails_extensions/geminator")'
        exit
      end
      
      YAML.load(ERB.new(File.open(config_file).read).result)
    end
    
    def copy_default_configuration
      config_yaml  = File.join(RAILS_ROOT, 'config', 'gems.yml')
      sample_yaml = File.dirname(__FILE__) + '/../../examples/gems.yml.sample'

      begin
        if File.exists?(config_yaml)
          puts "** You already have a #{config_yaml}.  " +  
               "Please check the sample for new settings or format changes."
          puts "You can find the sample at #{sample_yaml}."
        else
          puts "** Copying gems.yml.sample to #{config_yaml}..."
          FileUtils.cp(sample_yaml, config_yaml)
        end
      rescue
        puts "Error copying gems.yml.sample to #{config_yaml}.  Please try by hand."
      end
    end
  end
end



