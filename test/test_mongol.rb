require_relative 'helper.rb'

describe Mongol do

  it "must have a connection property" do
    Mongol.connection.wont_be_nil
    Mongol.connection.is_a?(Mongo::Connection).must_equal true
  end

end
