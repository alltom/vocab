full_path = File.expand_path(File.dirname(__FILE__))

require full_path + '/active_support/ordinalized_time'
require full_path + '/active_support/delegates'

class Time  #:nodoc:
  # Time.now.to_ordinalized_s :long
  # => "February 28th, 2006 21:10"
  def to_ordinalized_s(format = :default)
    format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[format] 
    return to_default_s if format.nil?
    strftime(format.gsub(/%d/, '_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
  end
end

Module.send(:include, EdgeCase::ActiveSupport::Provides::Delegates)