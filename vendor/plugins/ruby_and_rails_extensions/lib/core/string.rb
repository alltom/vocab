# originally from errtheblog.com
class String
  # >> 'chow:hound' / ':'
  # => ["chow", "hound"]
  def /(delimiter)
    split(delimiter)
  end

  def trim
    strip.squeeze(" ")
  end

  # Note: The following line was taken out due to it's dropping matcher variables
  # out of scope (and God knows what else). The method name as also changed to super_match
  # Removed by: Ryan Carmelo Briones - 2007/10/07
  #
  # alias :real_match :match
  
  # m = "12:34:56".super_match(/(\d+):(\d+):(\d+)/, :hour, :minute, :second)
  # puts m.hour
  # puts m.second
  def super_match(*args)
    return unless match = match(args.first) 
    returning match do |m|
      args[1..-1].each_with_index { |name, index| m.meta_def(name) { self[index+1] } }
    end
  end
end