# originally from errtheblog.com
class Object
  def returning(value)
    yield(value)
    value
  end unless respond_to? :returning

  # Metaid == a few simple metaclass helper
  # (See http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html.)
  # The hidden singleton lurks behind everyone
  def metaclass() class << self; self end end

  def meta_eval(&blk) metaclass.instance_eval(&blk) end

  # Adds methods to a metaclass
  def meta_def(name, &blk)
    meta_eval { define_method(name, &blk) }
  end

  # Defines an instance method within a class
  def class_def(name, &blk)
    class_eval { define_method(name, &blk) }
  end
end
