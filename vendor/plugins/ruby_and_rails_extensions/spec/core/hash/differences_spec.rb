require File.expand_path(File.dirname(__FILE__)) + '/../core_helper.rb'

describe Hash, ' - when using #substantial_differences_to' do
  before(:each) do
    @h = { 1 => 1, 2 => 3 }
  end

  it 'should consider blank objects to be equal' do
    {}.substantial_differences_to({}).should == {}
  end

  it 'should return a hash containing the entries that differ to the passed hash' do
    @h.substantial_differences_to({ 1 => 4, 2 => 3 }).should == { 1 => 1 }
  end
end

describe Hash, ' - when using #substantial_difference_to?' do
  it 'should return false if there are no changes' do
    {}.substantial_difference_to?({}).should be_false
  end

  it 'should return true if there are any changes' do
    { 1 => 1, 2 => 3 }.substantial_difference_to?({ 1 => 4, 2 => 3 }).should be_true
  end
end

describe Hash, ' - when using #audit_changes' do
  it 'should return a hash of keys indexing an array of the new value and then the previous value' do
    {1 => 2}.audit_changes({1 => 123}).should == {1 => [123, 2]}
  end
end
