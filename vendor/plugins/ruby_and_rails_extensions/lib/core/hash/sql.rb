module EdgeCase
  module Hash
    module Provides
      module SQL
        
        def to_sql
          sql = keys.sort {|a,b| a.to_s <=> b.to_s }.inject([[]]) do |arr, key|
            unless key.nil?
              arr[0] << "#{key} #{self[key] =~ /\%/ ? "LIKE" : "="} ?"
              arr << self[key]
            end
          end
          [sql[0].join(' AND ')] + sql[1..-1]
        end
        
      end
    end
  end
end