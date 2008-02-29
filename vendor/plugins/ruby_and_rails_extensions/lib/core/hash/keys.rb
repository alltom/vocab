module EdgeCase
  module Hash
    module Provides
      module Keys
        
        # from caboose_core
        def has_keys?(arr=[])
          return false if arr.nil?
          arr.each { |a| return false unless has_key?(a) }
        end
        
      end
    end
  end
end