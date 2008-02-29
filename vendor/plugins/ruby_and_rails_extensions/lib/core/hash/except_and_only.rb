module EdgeCase
  module Hash
    module Provides
      module ExceptAndOnly

        # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
        def except(*keys)
          self.reject { |k,v|
            keys.include? k
          }
        end

        # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
        def only(*keys)
          self.reject { |k,v|
            !keys.include? k
          }
        end
      
      end
    end
  end
end
