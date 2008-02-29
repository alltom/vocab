module RubyAndRailsExtensions
  
  def self.config
    @@config ||= Configuration.new
  end

  def self.configure(&block)
    raise "#configure must be sent a block" unless block_given?
    yield config
  end

  class Configuration
    attr_accessor :core
    attr_accessor :active_support
    attr_accessor :active_record
    
    def initialize
      @core = { :enabled => [:all], :disabled => [] }
      @active_support = { :enabled => [:all], :disabled => [] }
      @active_record = { :enabled => [:all], :disabled => [] }
    end
  end
end