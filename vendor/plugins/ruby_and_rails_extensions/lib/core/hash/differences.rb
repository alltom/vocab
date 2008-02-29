module EdgeCase
  module Hash
    module Provides
      module Differences

        # Return a hash containing the entries that differ to the passed hash.
        # Blank objects are considered equal.
        # 
        # { 1 => 1, 2 => 3 }.substantial_differences_to({ 1 => 4, 2 => 3 }) => { 1 => 1 }
        # { 1 => 1 }.substantial_differences_to({ 1 => 1 }) => {}
        def substantial_differences_to(hash)
          reject do |key, value|
            hash[key] == value || (hash[key].blank? && value.blank?)
          end
        end

        def substantial_difference_to?(hash)
          substantial_differences_to(hash).any?
        end
        
        def audit_changes(changed_attribute_hash)
          original_attribute_hash = self.dup
          # remove attributes that were not affected in this change
          original_attribute_hash.delete_if { |key,value| !changed_attribute_hash.has_key?(key) }
          merged_attributes = {}

          for attribute_key in changed_attribute_hash.keys
            merged_attributes[attribute_key] = [changed_attribute_hash[attribute_key], original_attribute_hash[attribute_key]]
          end
          merged_attributes
        end
      
      end
    end
  end
end