require File.expand_path(File.dirname(__FILE__)) + '/core_helper.rb'

describe Numeric, '#commify' do
  it 'should default to "," as the thousands separator' do
    1000.commify.should == '1,000'
  end

  it 'should be able to take an arbritary single character string as the thousands separator' do
    thousands_separator = '.'
    1000.commify('.', thousands_separator).should == "1#{thousands_separator}000"
  end

  it 'should default to "." as the decimal point' do
    12.34.commify.should == '12.34'
  end

  it 'should be able to take an arbritary single character string as the decimal point' do
    decimal_point = ','
    12.34.commify(decimal_point).should == "12#{decimal_point}34"
  end

  it 'should be able to insert commas in the thousands, millions, and billions place' do
    1234567890.12345.commify.should == "1,234,567,890.12345"
  end
end
