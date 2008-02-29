module NiceStrftime
  # cf. strftime (Time) http://www.ruby-doc.org/core/classes/Time.html#M000297
  NICE_STRFTIME_DIRECTIVES = {
    :abbr_weekday => :a,
    :weekday_name => :A,
    :abbr_month => :b,
    :month_name => :B,
    :preferred_local_date_and_time => :c,
    :day_of_the_month => :d,
    :hour_of_the_day_24 => :H,
    :hour_of_the_day_12 => :I,
    :day_of_the_year => :j,
    :month_of_the_year => :m,
    :minute_of_the_hour => :M,
    :meridian => :p,
    :second_of_the_minute => :S,
    :week_number_sunday => :U,
    :week_number_monday => :W,
    :day_of_the_week => :w,
    :preferred_date => :x,
    :preferred_time => :X,
    :year_no_century => :y,
    :year_with_century => :Y,
    :time_zone_name => :Z
  }

  def self.included(base)
    base.module_eval do
      include InstanceMethods
      base.extend ClassMethods
    end    
  end
  
  module ClassMethods
    def convert_nice_to_strftime_directives(directives)
      directives = directives.gsub(/([^\\]|^)(\:|%)(#{NICE_STRFTIME_DIRECTIVES.keys.join('|')})/) do
        "#{$1}%#{NICE_STRFTIME_DIRECTIVES[$3.to_sym]}"
      end

      directives = directives.gsub(/\\(\:|%)/) do
        $1
      end
    end
  end

  module InstanceMethods
    def nice_strftime(directives)
      self.strftime(self.class.convert_nice_to_strftime_directives(directives))
    end
  end
end
