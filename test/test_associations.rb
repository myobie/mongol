require_relative 'helper'

describe Mongol::Associations do

  describe "many" do
    it "must have a many method" do
      BookWithAuthors.must_respond_to :many
    end

    it "must return an array like thing" do
      @book = BookWithAuthors.new
      @book.authors.must_respond_to :each
    end

    it "must accept an array" do
      @book = BookWithAuthors.new
      @book.authors = [Author.create]
      @book.authors.size.must_equal 1
    end

    it "must save the array" do
      @book = BookWithAuthors.new
      @book.authors = [Author.create]
      @book.save
      BookWithAuthors.last.authors.size.must_equal 1
    end

    it "must save the items in the array" do
      @book = BookWithAuthors.new
      @book.authors = [Author.new]
      @book.save
      BookWithAuthors.last.authors.first.must_be_kind_of Author
    end

    it "must allow adding to the array with <<" do
      @book = BookWithAuthors.new
      @book.authors << Author.create
      @book.save
      BookWithAuthors.last.authors.first.must_be_kind_of Author
    end

    it "must allow adding tot he array with << then saving the items in the array" do
      @book = BookWithAuthors.new
      @book.authors << Author.new
      @book.save
      BookWithAuthors.last.authors.first.must_be_kind_of Author
    end

  end

end
