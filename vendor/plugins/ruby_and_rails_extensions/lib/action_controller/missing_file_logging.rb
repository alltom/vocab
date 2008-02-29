module EdgeCase
  module ActionController
    module Provides
      module MissingFileLogging

        private
        def log_error(exception) #:doc:
          if consider_all_requests_local || local_request? 
            if exception.is_a?(::ActionController::RoutingError) and exception.message =~ /(\.png|jpg|gif|css)/
              cleaned_message = exception.message.dup.gsub('No route matches','').gsub('"','').split(' with {').first.strip
              logger.fatal("  [MISSING FILE] ===> [#{cleaned_message}] <===")
              return
            end
          end                   
          super
        end

      end
    end
  end
end
