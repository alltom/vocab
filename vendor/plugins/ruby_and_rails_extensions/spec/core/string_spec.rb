require File.expand_path(File.dirname(__FILE__)) + '/core_helper.rb'

describe String, '#/' do
  it 'should just be a call split' do
    string = ''
    arg = 'arg'
    string.should_receive(:split).with(arg)
    string / arg
  end
end

describe String, '#trim' do
  it 'should just be a strip and then squeeze(" ") call' do
    string = ''
    string.should_receive(:strip).ordered.and_return(string)
    string.should_receive(:squeeze).ordered.with(' ').and_return(string)
    string.trim
  end
end

describe String, "#super_match" do
  before(:each) do
    @match_data = mock('MatchData')
    
    @string = "test"
    @regex = %r{(e)}
    
    @string.stub!(:match).and_return(@match_data)
  end
  
  it "should call match itself using the regex passed as the first argument" do
    @string.should_receive(:match).with(@regex)
    @string.super_match(@regex)
  end
  
  it "should inject the match data with accessors to the matches" do
    @string.should_receive(:returning).with(@match_data).and_yield(@match_data)
    @string.super_match(@regex)
  end
  
  it "should return a MatchData object with accessors matching the order and name of the args passed" do
    m = "12:34:56".super_match(/(\d+):(\d+):(\d+)/, :hour, :minute, :second)
    m.hour.should == "12"
    m.minute.should == "34"
    m.second.should == "56"
  end
  
  it "should not give the programmer access to match variables" do
    "test".super_match(/(e)/)
    $`.should be_nil
    $&.should be_nil
    $'.should be_nil
    $1.should be_nil
  end
end
