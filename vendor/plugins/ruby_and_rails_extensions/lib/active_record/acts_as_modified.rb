module EdgeCase
  module ActiveRecord
    module Provides
      module ModificationTracking

        def self.included(base)
          base.extend(ClassMethods)
        end
      
        mattr_accessor :excluded_attributes
        self.excluded_attributes = ['updated_at', 'updated_on', 'version', 'created_at', 'created_on', 'updated_by_id', 'created_by_id']
      
        module ClassMethods
          # == Configuration options
          # 
          # * <tt>clear_after_save</tt> - should the original attributes be cleared after saving, defaults to false. Causes <tt>modified?</tt> to return false after <tt>save</tt> has been called.
          def acts_as_modified(options = {})
            return if self.included_modules.include?(EdgeCase::ActiveRecord::Provides::ModificationTracking::InstanceMethods)
          
            options.assert_valid_keys :clear_after_save
          
            include InstanceMethods
          
            after_save :clear_original_attributes if options[:clear_after_save]
          
            # Replace with alias_method_chain once it's in stable
            alias_method :write_attribute_without_original_attributes, :write_attribute
            alias_method :write_attribute, :write_attribute_with_original_attributes
          
            alias_method :method_missing_without_modified, :method_missing
            alias_method :method_missing, :method_missing_with_modified
          
            alias_method :reload_without_clear_original_attributes, :reload
            alias_method :reload, :reload_with_clear_original_attributes
          
            alias_method :read_attribute_without_freeze, :read_attribute
            alias_method :read_attribute, :read_attribute_with_freeze
          
            alias_method :evaluate_read_method_without_freeze, :evaluate_read_method
            alias_method :evaluate_read_method, :evaluate_read_method_with_freeze
          end
        end
    
        module InstanceMethods
          # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+. Empty strings for fixnum and float columns are turned into nil.
          # The first call causes the original values of all attributes to be stored
          def write_attribute_with_original_attributes(attr_name, value) #:nodoc:
            ensure_original_attributes_stored
            write_attribute_without_original_attributes(attr_name, value)
          end
        
          def read_attribute_with_freeze(attr_name)
            read_attribute_without_freeze(attr_name).freeze
          end
        
          # Like +attributes_before_type_cast+, but returns original attributes
          def original_attributes_before_type_cast
            ensure_original_attributes_stored
            clone_attributes :read_original_attribute_before_type_cast
          end
        
          # Like +attributes+ but returns original attributes
          def original_attributes
            ensure_original_attributes_stored
            clone_attributes :read_original_attribute
          end
        
          # Like +read_attribute+ but returns original attribute value
          def read_original_attribute(attr_name)
            ensure_original_attributes_stored
            attr_name = attr_name.to_s
          
            if excluded_attribute?(attr_name)
              read_attribute(attr_name)
            else
              if !(value = @original_attributes[attr_name]).nil?
                if column = column_for_attribute(attr_name)
                  if unserializable_attribute?(attr_name, column)
                    unserialize_attribute(attr_name)
                  else
                    column.type_cast(value)
                  end
                else
                  value
                end
              else
                nil
              end
            end
          end
        
          # Like +read_attribute_before_type_cast+ but returns original attribute value
          def read_original_attribute_before_type_cast(attr_name)
            ensure_original_attributes_stored
            attr_name = attr_name.to_s
          
            if excluded_attribute?(attr_name)
              read_attribute_before_type_cast(attr_name)
            else
              @original_attributes[attr_name]
            end
          end
        
          # Replaces the current set of original values with the current attribute values.
          # This effectively makes it as if the attribute was never modified.
          # 
          #  person = Person.find(:first)
          #  person.name = 'New name'
          #  person.modified? # true
          #  person.clear_original_attributes
          #  person.modified? # false
          #
          # Pass :only or :except to refine the attributes that this is applied to.
          #
          #  person = Person.find(:first)
          #  person.name = 'New name'
          #  person.age = 49
          #  person.name_modified? # true
          #  person.age_modified? # true
          #  person.clear_original_attributes :only => :name
          #  person.name_modified? # false
          #  person.age_modified? # true
          def clear_original_attributes(options = {})
            if !(options[:only] or options[:except]) || !@original_attributes
              return @original_attributes = nil
            end
          
            attributes_to_clear = if options[:only]
              Array(options[:only]).map(&:to_s)
            elsif options[:except]
              except = Array(options[:except]).map(&:to_s)
              self.class.column_names.reject { |c| except.include?(c) }
            end
          
            attributes_to_clear.each do |attribute|
              @original_attributes[attribute] = @attributes[attribute]
            end
          end
        
          # Returns true if any of the attributes have changed. New records always return false.
          # Pass :reload to compare the current attributes against those in the database.
          # 
          #  person = Person.find(:first)
          #  person.modified? # false
          #  person.name = "New name"
          #  person.modified? # true
          #  person.modified?(:reload) # true
          def modified?(reload = nil)
            return false if new_record?
            return attributes.substantial_difference_to?(self.class.find(id).attributes) if reload
            original_attributes.substantial_difference_to?(attributes)
          end
        
          # Returns a hash containing changed attributes and their original values.
          #
          #  person = Person.find(:first)
          #  person.name # Jonathan
          #  person.name = 'New name'
          #  person.modified_attributes # { "name" => "Jonathan" }
          def modified_attributes
            original_attributes.substantial_differences_to(attributes)
          end
        
          # Restore the attributes to their original values. Use :only or :except to restore specific attributes.
          # 
          #  person = Person.find(:first)
          #  person.name # Jonathan
          #  person.age  # 100
          #  person.name = 'New name'
          #  person.age = 25
          #  
          #  person.restore_attributes # Restores name and age to original values
          #  person.restore_attributes :only => :name # Restores name to its original value
          #  person.restore_attributes :except => [:name, :age] # Restores all attributes except name and age to their original values
          def restore_attributes(options = {})
            original_attributes_before_type_cast = self.original_attributes_before_type_cast.dup
          
            if options[:only]
              only = Array(options[:only]).map(&:to_s)
              original_attributes_before_type_cast.delete_if { |key, value| !only.include?(key) }
            elsif options[:except]
              except = Array(options[:except]).map(&:to_s)
              original_attributes_before_type_cast.delete_if { |key, value| except.include?(key) }
            end
          
            @attributes.update(original_attributes_before_type_cast)
          end
        
          # Use +attribute+_modified? to find out if a specific attribute has been modified.
          # 
          #  person = Person.find(:first)
          #  person.name_modified? # false
          #  person.name = 'New name'
          #  person.name_modified? # true
          #
          # Use original_+attribute+ to get the original value of an attribute.
          # 
          #  person = Person.find(:first)
          #  person.name # 'Jonathan'
          #  person.name = 'Changed'
          #  person.original_name # Jonathan
          #
          # You can also call original_+association+ to get the original object of a belongs_to association.
          #
          #  Eg:
          #   +person.original_school+ instead of +School.find(person.original_school_id)+
          #
          #  person = Person.find(:first)
          #  person.school_id # 1
          #  person.school_id = 3
          #  person.original_school # will do School.find(1)
          def method_missing_with_modified(method_id, *arguments)
            method_name = method_id.to_s
            if md = /_modified\?$/.match(method_name)
              modified_attributes.has_key? md.pre_match
            elsif md = /^original_/.match(method_name)
              if self.class.column_names.include?(md.post_match)
                read_original_attribute(md.post_match)
              elsif reflection = self.class.reflections[md.post_match.to_sym]
                begin
                  reflection.klass.find(read_original_attribute(reflection.primary_key_name))
                rescue ActiveRecord::RecordNotFound
                end
              else
                method_mising_without_modified method_id, *arguments
              end
            else
              method_missing_without_modified method_id, *arguments
            end
          end
        
          # When Base#reload is called, the original attributes should be cleared
          def reload_with_clear_original_attributes #:nodoc:
            clear_original_attributes
            reload_without_clear_original_attributes
          end
        
         private
          def ensure_original_attributes_stored
            @original_attributes ||= @attributes.reject { |key, value| excluded_attribute?(key) }
          end
        
          def excluded_attribute?(attribute)
            EdgeCase::ActiveRecord::Provides::ModificationTracking.excluded_attributes.include?(attribute)
          end
        
          def evaluate_read_method_with_freeze(attr_name, method_definition)
            evaluate_read_method_without_freeze(attr_name, method_definition)
          
            unless method_definition =~ /#{attr_name}\?/ # Do not freeze <attr>? methods
              self.class.class_eval <<-END
                def #{attr_name}_with_freeze
                  #{attr_name}_without_freeze.freeze
                end
              END
            
              self.class.send(:alias_method, "#{attr_name}_without_freeze", attr_name)
              self.class.send(:alias_method, attr_name, "#{attr_name}_with_freeze")
            end
          end
        end

      end
    end
  end
end