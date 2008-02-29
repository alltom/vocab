module EdgeCase
  module ActiveRecord
    module Provides

      module WhoDunnit

        def track_who_dunnit
          belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
          belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
        end 

        def track_and_require_who_dunnit
          track_who_dunnit
          validates_presence_of :created_by
          validates_presence_of :updated_by
        end
        
      end
    end

  end
end