require 'erb'

# Discovered on the vast and wonderous internet at http://termos.vemod.net/hash-to_query_string
module EdgeCase
  module Hash
    module Provides
      module QueryString
        def to_query_string
          u = ERB::Util.method(:u)
          map { |k, v| u.call(k) + "=" + u.call(v) }.join("&")
        end
        alias_method :to_querystring, :to_query_string
      end
    end
  end
end