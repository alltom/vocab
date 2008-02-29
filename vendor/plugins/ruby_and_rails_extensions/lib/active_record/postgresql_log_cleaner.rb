# From: http://postgrelogcleaner.googlecode.com/svn/trunk/
# License:
# Copyright (c) 2007 [name of plugin creator]
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module EdgeCase
  module ActiveRecord
    module Provides
      module PostgresqlLogCleaning
        def self.included(base)
          base.class_eval do
            def log_info_with_system_call_filtering(sql, name, runtime)
              unless sql && sql.include?('FROM pg_')
          	    log_info_without_system_call_filtering(sql, name, runtime)
              end
            end

            alias_method_chain :log_info, :system_call_filtering
          end
        end
        
      end
    end
  end
end