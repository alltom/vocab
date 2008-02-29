class Array
  # originally from errtheblog.com
  # >> [[:dog, true], [:cat, true]].to_hash
  # => { :dog => true, :cat => true }
  def to_hash
    Hash[*inject([]) { |array, (key, value)| array + [key, value] }]
  end
  
  # from caboose_core
  def smoosh 
    self.flatten.compact.uniq
  end

  # from caboose_core
  def cycle(pattern = %w(odd even))
    self.each_with_index { |o,i| yield(o, pattern[i % pattern.size]) }
  end
end
