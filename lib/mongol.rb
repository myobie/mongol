require 'mongo'
require 'forwardable'
require 'plucky'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/inflector'
require 'active_support/concern'

module Mongol
  VERSION = '0.0.1'

  def self.connection
    @connection
  end

  def self.database
    @database
  end
  def self.database=(new_database)
    @database = new_database
    @connection = new_database.connection
  end
end

require_relative 'mongol/document'
