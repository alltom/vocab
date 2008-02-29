# Borrowed with the best of intentions from Senor Halloway and Relevance

module EdgeCase
  module ActiveSupport
    module Provides
      module Delegates
        # Provides an alternative to Rails' delegate method. We needed two things
        # that Rails did not do: delegate from one method name to another, and 
        # provide a default value if the delegate object is nil. :to is required
        # :method is optional (default is the method name being called)
        # :default is optional (default is to blow up if the delegate is nil)
        # 
        # Usage
        #   class Foo < ActiveRecord::Base
        #     super_delegate :hello, :to => :greeter, :as=>:salutation, :default=>'Cheers'
        #   end
        #

        def super_delegate(*methods)
          options = methods.pop
          
          unless options.is_a?(::Hash) && options.has_key?(:to)
            raise ArgumentError, "Delegation needs a :to option"
          end
          to = options[:to]

          method_to, default, visibility = options[:as], options[:default], options[:visibility]
          
          method_from = methods.pop
          method_to = method_to ? method_to : method_from
          # TODO: how to pass a block?
          define_method(method_to) do |*args|
            self.send(to) ? self.send(to).send(method_from,*args) : default
          end


            
         
          if visibility
            self.send(visibility, *methods)
          end
        end
        
        
      end
    end
  end
end