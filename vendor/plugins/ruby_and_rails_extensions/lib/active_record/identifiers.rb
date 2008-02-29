module EdgeCase
  module ActiveRecord
    module Provides
      module RecordIdentifiers
      
        # person.dom_id #-> "person-5"
        # new_person.dom_id #-> "person-new"
        # new_person.dom_id(:bare) #-> "new"
        # person.dom_id(:person_name) #-> "person-name-5"
        def dom_id(prefix=nil)
          display_id = new_record? ? "new" : id
          prefix ||= self.class.name.underscore
          prefix != :bare ? "#{prefix.to_s.dasherize}-#{display_id}" : display_id
        end
      
        def referenced_cache_key
          "[#{[id, self.class.name] * ':'}]"
        end
      
      end      
    end
  end
end