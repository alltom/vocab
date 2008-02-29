module EdgeCase
  module ActiveRecord
    module Provides
      module Accessibility
        
        def each(*args, &block)
          if block_given?
            self.find(:all, *args).each do |result|
              yield result
            end
          else
            self.find(:all, *args).each
          end
        end
        
      end
    end
  end
end