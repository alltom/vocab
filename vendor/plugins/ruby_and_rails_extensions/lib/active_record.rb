full_path = File.expand_path(File.dirname(__FILE__))

require("#{full_path}/active_record/acts_as_friendly_param")
require("#{full_path}/active_record/acts_as_modified")
require("#{full_path}/active_record/accessibility")
require("#{full_path}/active_record/enhanced_local_logging")
require("#{full_path}/active_record/fixture_dumping")
require("#{full_path}/active_record/identifiers")
require("#{full_path}/active_record/migration")
require("#{full_path}/active_record/postgresql_log_cleaner")
require("#{full_path}/active_record/validates_email")
require("#{full_path}/active_record/who_dunnit")

class ActiveRecord::Base  #:nodoc:
  extend EdgeCase::ActiveRecord::Provides::Accessibility
  extend EdgeCase::ActiveRecord::Provides::WhoDunnit
  include EdgeCase::ActiveRecord::Provides::FixtureDumping
  include EdgeCase::ActiveRecord::Provides::RecordIdentifiers
  include EdgeCase::ActiveRecord::Provides::FriendlyParam
  include EdgeCase::ActiveRecord::Provides::ModificationTracking
  include EdgeCase::ActiveRecord::Provides::ValidatesEmail
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter  #:nodoc:
  include EdgeCase::ActiveRecord::Provides::EnhancedLocalLogging 
  include EdgeCase::ActiveRecord::Provides::PostgresqlLogCleaning 
end

require 'dispatcher' unless defined?(::Dispatcher)
::Dispatcher.to_prepare :ruby_and_rails_extensions do
  require("#{full_path}/active_record/query_trace") unless RubyAndRailsExtensions.config.active_record[:disabled].include?(:query_trace)
end