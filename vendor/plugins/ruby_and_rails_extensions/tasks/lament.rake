require 'tempfile'

#from http://www.bigbold.com/snippets/posts/show/2317
#APP_VERSION = IO.popen("svn info").readlines[2].split(' ').last

class Subversion

  def run( command, options = {} )
    defaults = { :message => "ERROR: svn error", :expect_error => false, :capture_output => false }
    options = defaults.merge(options)
    
    command_line = "svn #{command}"
    # puts "running: #{command_line}"
    if options[:capture_output]
      output = `#{command_line}`
      result = $?.success?
      puts output
    else
      result = system command_line
    end
    if (options[:expect_error] && result) || (!options[:expect_error] && !result)
      $stderr.puts "#{options[:message]} running #{command_line}"
      exit 1
    end
    output
  end

  def ignore( filename, directory )
    propadd 'ignore', directory, filename
  end
  
  def propadd( property, dir, content )
    originals = propget( property, dir )
    new_ones = (originals + [content]).uniq
    propset( property, dir, new_ones )
  end

  def propdel( property, dir, content )
    originals = propget( property, dir )
    new_ones = (originals - [content]).uniq
    propset( property, dir, new_ones )
  end

  def propget( property, dir )
    ext = run "propget #{property} \"#{dir}\"", :capture_output => true
    ext.reject{ |line| line.strip == '' }.map {|line| line.strip}
  end

  def commit( dir, message )
    Tempfile.open("svn-commit") do |file|
      file.write(message)
      file.flush
      run "commit #{dir} -F \"#{file.path}\""
    end
  end

  def propset( property, dir, lines )
    unless lines.is_a? String
      lines = lines.join("\n")
    end
    Tempfile.open("svn-set-prop") do |file|
      file.write(lines)
      file.flush
      run "propset -q #{property} -F \"#{file.path}\" \"#{dir}\""
    end
  end
  
end

@svn = Subversion.new

def root_dir( escaped = true )
  escaped ? 
  Rake.original_dir.gsub(' ', '\ ') :
  Rake.original_dir
end

def ye_interactive_svn_adventure(the_mage_art_stupid = false, thou_art_this_slow = 1)
  system('clear')

  puts ''
  puts "Starting SCM Manager . . ."    
  
  # if the_mage_art_stupid
    # puts "Ahh, thy hath invoked ye olde interactive SCM manager once again.  Didst thou pick the short wand at magic school?  This makes #{thou_art_this_slow}-eth times."
  # else
    # puts 'Ahh, thy hath invoked ye olde interactive SCM manager.  Good for thou!'
  # end
  puts ''

  puts 'Who worked on this changeset?'
  @pair = STDIN.gets.chomp
  puts ''

  puts "Please enter any story numbers this changeset is in regards to:"
  @story = STDIN.gets.chomp
  puts ''

  puts "Please enter a description of your changeset:"
  @what = STDIN.gets.chomp
  puts ''

  @message = "[#{@pair}] "
  @message << "STORY##{@story} " unless @story.empty?
  @message << @what

  @message
end

desc "Lament your tales of woe to the repository"
task :lament do
  @message = ye_interactive_svn_adventure.strip
  @number_of_failures = 1

  while @message == '[]'
    @message = ye_interactive_svn_adventure(true, @number_of_failures += 1)
  end

  puts "SVN: Checking in your changeset now . . ."
  @svn.commit root_dir, @message
end

desc "This one is for my can't type 6 letter coworkers"
task :s => :lament

desc "Commit that code, awww yeah."
task :commit => :lament

desc "Check it in, check it in"
task :checkin => :lament