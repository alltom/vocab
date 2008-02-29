require File.expand_path(File.dirname(__FILE__)) + '/core_helper.rb'

describe Array, '#to_hash' do
  it 'should convert an array of arrays (that have two values) and convert it into a hash with the first value of the tuple-array as a key and the last value as the value' do
    [[:dog, true], [:cat, true]].to_hash.should == { :dog => true, :cat => true }
  end
end

describe Array, '#smoosh' do
  it 'should just call flatten.compact.uniq' do
    array = []
    array.should_receive(:flatten).ordered.and_return(array)
    array.should_receive(:compact).ordered.and_return(array)
    array.should_receive(:uniq).ordered.and_return(array)
    array.smoosh
  end
end
