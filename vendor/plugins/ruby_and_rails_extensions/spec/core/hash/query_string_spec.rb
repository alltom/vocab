require File.expand_path(File.dirname(__FILE__)) + '/../core_helper.rb'

describe Hash, ' - when using #to_query_string' do
  before(:each) do
    @h = {'username' => 'someuser', :email => 'someuser@someuser.com'}
  end

  it 'should join the elements with "&"' do
    @h.to_query_string.count('&').should == (@h.size-1)
  end

  it 'should escape characters for url' do
    h = {'body' => '<tag>should be escaped</tag>'}
    h.to_query_string.should_not include('/')
    h.to_query_string.should_not include('<')
    h.to_query_string.should_not include('>')
  end

  it 'should have to_querystring aliased to to_query_string' do
    @h.to_querystring.should == @h.to_query_string
  end
end
