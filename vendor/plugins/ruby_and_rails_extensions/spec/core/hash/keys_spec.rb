require File.expand_path(File.dirname(__FILE__)) + '/../core_helper.rb'

describe Hash, ' - when using #has_keys?' do
  before(:each) do
    @h = {'string' => 'value indexed via "string"', :symbol => 'value indexed via :symbol'}
  end

  it 'should return false when asked if it has nil as a key' do
    @h.has_keys?(nil).should be_false
  end

  it 'should return false if one of asked for keys does not exist' do
    @h.has_keys?([:no_such_key]).should be_false
    @h.has_keys?(['string', :no_such_key]).should be_false
    @h.has_keys?([:symbol, :no_such_key]).should be_false
  end

  it 'should return the array of the given keys if all are present' do
    @h.has_keys?(['string']).should == ['string']
  end
end
