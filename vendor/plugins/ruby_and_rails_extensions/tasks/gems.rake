require 'yaml'
require File.dirname(__FILE__) + '/../lib/support/gem_tools'

namespace :gems do
  require 'rubygems'

  desc "Install required gems based on config/gems.yml"
  task :install do
    # defaults to --no-rdoc, set DOCS=(anything) to build docs
    docs = ''
    docs << '--no-ri ' unless (`ri -v`).nil?
    
    if ENV['DOCSs'].nil?
      docs << '--no-rdoc ' unless (`rdoc -v`).nil?
    end

    #grab the list of gems/version to check
    config = GemTools.load_gem_configuration
    gems = config["gems"]

    unless gems.nil?
      gems.each do |gem|
        # load the gem spec
        gem_spec = YAML.load(`gem spec #{gem['name']} 2> /dev/null`)
        gem_loaded = false
        begin
          if gem['version'].nil?
            gem_loaded = require_gem gem['name']
          else
            gem_loaded = require_gem gem["name"], gem["version"]
          end
        rescue Exception
        end

        # if forced
        # or there is no gem_spec
        # or the spec version doesn't match the required version
        # or require_gem returns false
        #    (return false also happens if the gem has already been loaded)
        gem_version_equal = (gem['version'].nil? ? true : gem_spec.version.version != gem["version"])
        gem_name_and_version = "#{gem['name']}#{gem['version'].nil? ? '' : ' ' + gem['version']}"
        
        if !ENV['FORCE'].nil? || !gem_spec || (gem_version_equal && !gem_loaded)
          gem_config = gem["config"] ? " -- #{gem['config']}" : ''
          source = gem["source"] || config["source"] || nil
          source = "--source #{source}" if source
          
          cmd = ''
          puts "Attempting to install #{gem_name_and_version}. If this fails try running the rake task as sudo."
          if gem["path"]
            cmd = "gem install #{gem['path']} #{source} #{docs} #{gem_config}"
          else
            gem['version'] = ('-v ' + gem['version']) unless gem['version'].nil?
            cmd << "gem install #{gem['name']} '#{gem['version']}' -y #{source} #{docs} #{gem_config}"
          end
          puts "Running cmd =>"

          ret = %x[#{cmd}]
          # something bad happened, pass on the message
          p $? unless ret
        else
          puts "#{gem_name_and_version} is already installed."
        end
      end
    end
  end

  desc "Freeze a gem to /vendor/gems.  You can specify GEM=gemname and VERSION=ver"
  task :freeze do
    raise "No gem specified" unless gem_name = ENV['GEM']

    Gem.manage_gems

    gem = (version = ENV['VERSION']) ? Gem.cache.search(gem_name, "= #{version}").first : Gem.cache.search(gem_name).sort_by { |g| g.version }.last

    version ||= gem.version.version rescue nil

    unless gem && path = Gem::UnpackCommand.new.get_path(gem_name, version)
      raise "No gem #{gem_name} #{version} is installed.  Do 'gem list #{gem_name}' to see what you have available."
    end

    target_dir = ENV['TO'] || File.basename(path).sub(/\.gem$/, '')

    gem_target_dir = File.expand_path("#{RAILS_ROOT}/vendor/gems/#{gem_name}-#{version}")

    rm_rf gem_target_dir

    mkdir_p gem_target_dir
    
    puts "Found gem at #{path}"
    
    Gem::Installer.new(path).unpack(gem_target_dir)
    
    puts "Unpacked #{gem_name} #{version} to '#{gem_target_dir}'"
  end

  desc "Unfreeze a gem in /vendor/gems.  You can specify GEM=gemname"
  task :unfreeze do
    raise "No gem specified" unless gem_name = ENV['GEM']
    Dir["#{RAILS_ROOT}/vendor/gems/#{gem_name}-*"].each { |d| rm_rf d }
  end

end