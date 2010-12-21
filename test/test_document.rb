require_relative 'helper'

describe Mongol::Document do

  it "must initialize with attributes" do
    @book = Book.new title: 'Moby Dick'
    @book.attributes.must_equal title: 'Moby Dick'
  end

  it "must allow setting of attributes=" do
    @book = Book.new title: 'Something'
    @book.attributes = { author: 'Me' }
    @book.attributes.must_equal author: 'Me'
  end

  it "must allow accessing attributes with []" do
    @book = Book.new title: 'Something'
    @book[:title].must_equal 'Something'
  end

  it "must allow setting of attributes with []=" do
    @book = Book.new title: 'Something'
    @book[:title] = 'Something Else'
    @book[:title].must_equal 'Something Else'
  end

  it "must always keep keys as symbols" do
    @book = Book.new "title" => 'Something'
    @book.attributes.must_equal title: 'Something'
  end

  it "must fetch id" do
    @book = Book.new
    @book.id.must_be_nil
    @book.save
    @book.id.wont_be_nil
  end

  it "must allow setting of id=" do
    @book = Book.new
    @book.id = 1
    @book.id.must_equal 1
  end

  it "must be new" do
    @book = Book.new
    @book.new_document?.must_equal true
  end

  it "must not be new if saved" do
    @book = Book.create
    @book.new_document?.must_equal false
  end

  it "must not be saved" do
    @book = Book.new
    @book.saved?.must_equal false
  end

  it "must be saved if saved" do
    @book = Book.new
    @book.save
    @book.saved?.must_equal true
  end

  it "must persist if saved" do
    @book = Book.new
    @book.save
    Book.first.must_equal @book
  end

  it "must return true when saving" do
    @book = Book.new
    @book.save.must_equal true
  end

  it "must return true when saving an existing document" do
    @book = Book.create
    @book[:title] = 'Something New'
    @book.save.must_equal true
  end

  it "must return true when updating" do
    @book = Book.create
    @book.update(title: 'Something new').must_equal true
  end

  it "must allow updating of some attributes" do
    @book = Book.create title: 'Something'
    @book.update_attributes author: 'Me'
    @book[:title].must_equal 'Something'
    @book[:author].must_equal 'Me'
  end

  it "must destroy itself" do
    @book = Book.create
    Book.count.must_equal 1
    @book.destroy
    Book.count.must_equal 0
  end

  it "must be aware if it has been destroyed" do
    @book = Book.create
    @book.destroy
    @book.destroyed?.must_equal true
  end

  it "must keep track of it's collection" do
    Book.collection.must_be_kind_of Mongo::Collection
  end

  it "must allow creation with attributes directly" do
    @book = Book.create title: 'Moby Dick'
    @book.saved?.must_equal true
    @book[:title].must_equal 'Moby Dick'
  end

  it "must allow indexes to be set" do
    Book.index :title
    Book.collection.index_information.keys.must_include "title_1"
  end

  it "must allow indexes to be dropped" do
    Book.index :title
    Book.drop_indexes
    Book.collection.index_information.keys.wont_include "title_1"
  end

  it "must perform materialization" do
    Book.materialize(title: 'Moby Dick').must_be_kind_of Book
    Book.materialize([{title: '1'}, {title: '2'}]).must_be_kind_of Array
  end

end

