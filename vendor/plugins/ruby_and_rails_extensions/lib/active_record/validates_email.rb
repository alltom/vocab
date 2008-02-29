module EdgeCase
  module ActiveRecord
    module Provides

      module ValidatesEmail

        def self.included(base)
          base.class_eval do
            def self.validates_email(attr_name, conf = {})
              conf.reverse_merge!({:with => Regexp::RFC822_EMAIL_ADDRESS, :message => "is invalid", :on => :save, :allow_nil => false})
              validates_format_of attr_name, conf
            end
          end
        end
      end

    end
  end
end
