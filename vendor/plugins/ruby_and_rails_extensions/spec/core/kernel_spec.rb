require File.expand_path(File.dirname(__FILE__)) + '/core_helper.rb'

describe Kernel, '#random_n_digit_number' do
  it 'should raise an ArgumentError if the digit length is zero' do
    lambda{ random_n_digit_number(0) }.should raise_error(ArgumentError)
  end

  it 'should raise an ArgumentError if the digit length is less than zero' do
    lambda{ random_n_digit_number(-1) }.should raise_error(ArgumentError)
  end

  it 'should raise an ArgumentError if the digit length is not a numeric' do
    lambda{ random_n_digit_number(nil) }.should raise_error(ArgumentError)
  end
end

describe Kernel, ' - when generating a random 1 digit number' do
  before(:all) do
    @smallest_number = 0
    @largest_number = 9
  end

  it 'should generate the smallest number of 0' do
    stub!(:rand).and_return(@smallest_number)
    random_n_digit_number(1).should == @smallest_number
  end

  it 'should generate the largest number of 9' do
    stub!(:rand).and_return(@largest_number)
    random_n_digit_number(1).should == @largest_number
  end
end

describe Kernel, ' - when generating a random 2 digit number' do
  before(:all) do
    @smallest_number = 10
    @largest_number = 99
  end

  it 'should generate the smallest number of 10' do
    stub!(:rand).and_return(0)
    random_n_digit_number(2).should == @smallest_number
  end

  it 'should generate the largest number of 99' do
    stub!(:rand).and_return(@largest_number-@smallest_number)
    random_n_digit_number(2).should == @largest_number
  end
end
