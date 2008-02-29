require File.expand_path(File.dirname(__FILE__)) + '/core_helper.rb'

describe Time, ' - when converting nice directives into strftime directives' do
  it 'should convert a nice directive starting with a "%" or a ":" into an strftime directive' do
    Time.convert_nice_to_strftime_directives('%abbr_weekday').should == '%a'
    Time.convert_nice_to_strftime_directives(':abbr_weekday').should == '%a'
  end

  Time::NICE_STRFTIME_DIRECTIVES.each do |nice_directive,strftime_directive|
    it "should convert :#{nice_directive} to %#{strftime_directive}" do
      Time.convert_nice_to_strftime_directives(":#{nice_directive}").should == "%#{strftime_directive}"
    end
  end

  it 'should preserve the %% directive' do
    Time.convert_nice_to_strftime_directives('%%').should == '%%'
  end

  it 'should not convert an escaped DSL' do
    Time.convert_nice_to_strftime_directives("\\:weekday").should == ':weekday'
  end

  it 'should preserve existing strftime directives' do
    directives = '%a %A %b %B %c %d %H %I %j %m %M %p %S %U %W %w %x %X %y %Y %Z'
    Time.convert_nice_to_strftime_directives(directives).should == directives
  end
end

describe Time, '#nice_strftime' do
  it 'should call #strftime with the converted nice directives' do
    directive = '%a'

    Time.should_receive(:convert_nice_to_strftime_directives).and_return(directive)

    t = Time.now
    t.should_receive(:strftime).with(directive)

    t.nice_strftime(directive)
  end
end
