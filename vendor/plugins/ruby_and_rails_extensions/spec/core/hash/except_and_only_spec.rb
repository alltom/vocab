require File.expand_path(File.dirname(__FILE__)) + '/../core_helper.rb'

describe Hash, ' - when using #only' do
  before(:each) do
    @h = {'string' => 'value indexed via "string"', :symbol => 'value indexed via :symbol'}
  end

  it 'should be able to return the key-value pair when given a single key' do
    @h.only('string').should == {'string' => 'value indexed via "string"'}
  end

  it 'should be able to return the key-value pairs when given multiple keys' do
    @h.only('string', :symbol).should == {'string' => 'value indexed via "string"', :symbol => 'value indexed via :symbol'}
  end

  it 'should be able to return the key-value pairs when the keys are strings' do
    @h.only('string').should == {'string' => 'value indexed via "string"'}
  end

  it 'should be able to return the key-value pairs when the keys are symbols' do
    @h.only(:symbol).should == {:symbol => 'value indexed via :symbol'}
  end

  it 'should return an empty hash when no keys matched' do
    @h.only(:non_extant_key).should == {}
  end

  it 'should preserve the hash after a key was solicited' do
    original_hash = @h.dup
    @h.only(@h.keys)
    @h.should == original_hash
  end
end

describe Hash, ' - when using #except' do
  before(:each) do
    @h = {'string' => 'value indexed via "string"', :symbol => 'value indexed via :symbol'}
  end

  it 'should be able to return the key-value pair when given a single key' do
    @h.except('string').should == {:symbol => 'value indexed via :symbol'}
  end

  it 'should be able to return the key-value pairs when given multiple keys' do
    @h.except('string', :symbol).should == {}
  end

  it 'should be able to return the key-value pairs when the keys are strings' do
    @h.except('string').should == {:symbol => 'value indexed via :symbol'}
  end

  it 'should be able to return the key-value pairs when the keys are symbols' do
    @h.except(:symbol).should == {'string' => 'value indexed via "string"'}
  end

  it 'should return the original hash when no keys matched' do
    @h.except(:non_extant_key).should == @h
  end

  it 'should preserve the hash after a key was exempted' do
    original_hash = @h.dup
    @h.except(@h.keys)
    @h.should == original_hash
  end
end
