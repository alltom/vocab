require 'yaml'

namespace :spec do

  # Idea from ErrTheBlog, converted to RSpec 0.9.2 describe format here
  # Give it a yml file in the format of
  # A User, in general:
  #   - should be able to digg a story
  #   - should not be able to digg a story twice
  #   - should be able to tell if he has dugg a story
  desc "Converts a YAML file into a RSpec skeleton"
  task :generate_specs_from_yaml do
    if ENV['FILE'].nil?
      puts "Please provide a FILE to convert via FILE=your_spec_file.yml"
      exit
    end
    
    spec_yml = YAML.load_file(ENV['FILE'])
    specification = "require File.dirname(__FILE__) + '/../spec_helper'\n\n"
    
    spec_yml.each do |spec|
    
      spec.flatten!
      describe = spec.shift
      friendlier_describe = describe.split(',')
      
      describe = friendlier_describe.shift.gsub('An ','').gsub('A ','').strip
      
      if friendlier_describe.any?
        describe << ", \"#{friendlier_describe.join(' ')}\""
      end
      
      specification << "describe #{describe} do\n\n"
      
      spec.each do |example|
        specification << "  it \"#{example}\" do\n\n"
        specification << "  end\n\n"
      end
      
      specification << "end\n\n"
      
    end
    
    puts specification
    # spec = spec_yml.inject(''){ |t, (c,s)|
    # 
    #   puts
    #   t + (s ?%.describe "#{c}" do.+ s.map{ |d| %.\n  xspecify "#{d}" do\n  end\n. } * '' + "end\n\n":'')
    # }.strip
    # 
    # puts spec

  end
  
end