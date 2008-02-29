require 'iconv'
# Taken From ActsAsFriendlyParam
# Thanks to Mephisto for the iconv character translation code

module EdgeCase
  module ActiveRecord #:nodoc:
    module Provides #:nodoc:
    
      # Use this act if you want your models to use more descriptive :id fields in URLs
      # A model using acts_as_friendly_param may have a RESTful URL such as:
      #
      # /posts/4-the-day-the-earth-stood-still
      #
      module FriendlyParam
      
        # ClassMethods inheritance hack
        #
        def self.included(base) # :nodoc:
          base.extend ClassMethods
        end
      
        module ClassMethods
        
          # macro for enabling this act
          # by default friendly-param will try and use a
          # method called #name to find the name of the record
          # but you may specify another ie.
          #
          # acts_as_friendly_param :title
          # 
          # other options are for customising iconv charmap translation
          # methods ie.
          #
          # acts_as_friendly_param :name, :translation_to => 'utf-16'
          #
          # 
          def acts_as_friendly_param(name_method=:name, options={})
            # set translation methods
            #
            translation_to = options.fetch(:translation_to, 'ascii//ignore//translit')
            translation_from = options.fetch(:translation_from, 'utf-8')
            #
            # construct the to_param method
            #  
            define_method :to_param do
              param = id.to_s
              if respond_to?(name_method) && name = send(name_method)
                s = Iconv.iconv(translation_to, translation_from, name).to_s
                s.gsub!(/[^a-zA-Z0-9\-_]+/, ' ') # all non-word chars to spaces
                s.strip!            # ohh la la
                s.downcase!         #
                s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
                param << '-' + s
              end
              param
            end
            #
            # since the URLs are to be based on the #name_method
            # it seems logical that the #name_method should be required and validated
            # against by default?
            # 
            # do something?
          
            # 
            # by default a RecordMoved error will be raised if the ID is matched
            # but the title text doesnt. to disable this feature use 
            # 
            # acts_as_friendly_param :name, :strict => false
            #
            if options.fetch(:strict, true)
              #
              # overide the default [internal] #find_one method to check that
              # the requested URL title matches the current model.
              # this is important for SEO, where ranking can be adversly affected
              # by multiple URLs pointing to the same content
              #
              class_eval do
                def self.find_one(id, options)
                  record = super(id, options)
                  #
                  # check title text if the id is a string and more than
                  # just a string version of an integer.
                  #  
                  if id.kind_of?(String) && (id != record.to_param)
                    raise RecordMoved.new(record), "A record with id=#{id.to_i.to_s} was found but '#{id.gsub(/^[0-9\-]+/,'')}' did not match"
                  end
                  record
                end
              end
            end
            #
          end 
               
        end #ClassMethods
      
      end #FriendlyParam
    
    end
  end
end