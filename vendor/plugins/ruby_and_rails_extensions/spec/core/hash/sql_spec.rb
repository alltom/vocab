require File.expand_path(File.dirname(__FILE__)) + '/../core_helper.rb'

describe Hash, ' - when using #to_sql' do
  before(:each) do
    @h = {'username' => 'someuser', :email => 'someuser%'}
  end

  it 'should return an array' do
    @h.to_sql.is_a?(Array).should be_true
  end

  it 'should contain values of the hash' do
    @h.values.each do |value|
      @h.to_sql.should include(value)
    end
  end

  it 'should contain a string in the first element that is joined with "AND"' do
    @h.to_sql.first.scan('AND').size.should == (@h.size - 1)
  end

  it 'should have the "LIKE" comparison when the value contains a "%" character' do
    {:email => 'a % value'}.to_sql.first.should include('email LIKE ?')
  end

  it 'should have the "=" comparison when the value does not contain a "%" character' do
    {:username => 'non percent value'}.to_sql.first.should include('username = ?')
  end
end
