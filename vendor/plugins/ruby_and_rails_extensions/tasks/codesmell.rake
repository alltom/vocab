class SourceSmeller
  class CodeyBits < Struct.new(:line, :tag, :text)
    def to_s(options={})
      s = "[%3d] " % line
      s << "[#{tag}] " if options[:tag]
      s << text unless text.nil?
    end
  end

  def self.enumerate(tag, options={})
    extractor = new(tag)
    extractor.display(extractor.find, options)
  end

  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def find(dirs=%w(app lib test spec))
    dirs.inject({}) { |h, dir| h.update(find_in(dir)) }
  end

  def find_in(dir)
    results = {}

    Dir.glob("#{dir}/*") do |item|
      next if File.basename(item)[0] == ?.

      if File.directory?(item)
        results.update(find_in(item))
      elsif item =~ /\.r(?:b|xml|js)$/
        results.update(extract_annotations_from(item, /#\s*(#{tag}):?\s*(.*)$/))
      elsif item =~ /\.(rhtml|html\.erb|erb)$/
        results.update(extract_annotations_from(item, /<%\s*#\s*(#{tag}):?\s*(.*?)\s*%>/))
        results.update(extract_annotations_from(item, /(#{tag.downcase}):?\s*(.*)$/))
      end
    end

    results
  end

  def extract_annotations_from(file, pattern)
    lineno = 0
    result = File.readlines(file).inject([]) do |list, line|
      lineno += 1
      next list unless line =~ pattern
      list << CodeyBits.new(lineno, $1, $2)
    end
    result.empty? ? {} : { file => result }
  end

  def display(results, options={})
    results.keys.sort.each do |file|
      puts "#{file}:"
      results[file].each do |note|
        puts "  * #{note.to_s(options)}"
      end
      puts
    end
  end
end

VARIOUS_CODE_SMELLS = %w(OPTIMIZE FIXME TODO NEEDS_DESIGNER)
desc "List all the fragrant odors of the code."
task :codesmell do
  SourceSmeller.enumerate VARIOUS_CODE_SMELLS.join('|'), :tag => true
end

namespace :codesmell do
  VARIOUS_CODE_SMELLS.each do |what_is_that_i_smell|
    desc "I wish to smell all of the #{what_is_that_i_smell}"
    task what_is_that_i_smell.downcase.to_sym do
      SourceSmeller.enumerate what_is_that_i_smell
    end
  end
end