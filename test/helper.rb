$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'mongol'
require 'pp'
require 'minitest/autorun'

Mongol.database = Mongo::Connection.new.db("just-mongo-test")

class MiniTest::Unit::TestCase
  def setup
    Mongol.database.collections.map do |collection|
      collection.remove
      collection.drop_indexes
    end
  end
end

class Book
  include Mongol::Document
end
