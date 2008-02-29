require 'active_support' unless defined?(::ActiveSupport)

full_path = File.expand_path(File.dirname(__FILE__))

require full_path + '/hash/differences'
require full_path + '/hash/except_and_only'
require full_path + '/hash/keys'
require full_path + '/hash/query_string'
require full_path + '/hash/sql'

class Hash  #:nodoc:
  include EdgeCase::Hash::Provides::Differences
  include EdgeCase::Hash::Provides::ExceptAndOnly
  include EdgeCase::Hash::Provides::Keys
  include EdgeCase::Hash::Provides::QueryString
  include EdgeCase::Hash::Provides::SQL
end
