# Change the logging slightly so it chops out the annoying eager-loading code (t1_t2 AS foo)
# and shows a returned record count in the sql log.
#
module EdgeCase
  module ActiveRecord
    module Provides
      module EnhancedLocalLogging
        def self.included(base)
          base.class_eval do
            protected
              def log_info_with_eager_filtering(sql, name, runtime, result_size = 0)
                # if name =~ /Load Including Associations$/
                #   sql = sql.scan(/SELECT /).to_s + ' ...<snip>... ' + sql.scan(/(FROM .*)$/).to_s
                # end
                name = "#{name} (#{result_size.to_i})"
                log_info_without_eager_filtering(sql, name, runtime)
              end
              alias_method_chain :log_info, :eager_filtering
            end
          end
      end
    end
  end
end