module EdgeCase
  module ActiveRecord
    module Provides
      module FixtureDumping
      
        # http://rails.techno-weenie.net/tip/2005/12/23/make_fixtures
        def to_test_fixture(fixture_path = nil)
          File.open(File.expand_path(fixture_path || "test/fixtures/#{table_name}.yml", RAILS_ROOT), 'w') do |out|
            YAML.dump find(:all).inject({}) { |hsh, record| hsh.merge(record.id => record.attributes) }, out
          end
        end

      	def to_spec_fixture(fixture_path = nil)
          File.open(File.expand_path(fixture_path || "spec/fixtures/#{table_name}.yml", RAILS_ROOT), 'w') do |out|
            YAML.dump find(:all).inject({}) { |hsh, record| hsh.merge(record.id => record.attributes) }, out
          end
        end  
      
      end
    end
  end
end