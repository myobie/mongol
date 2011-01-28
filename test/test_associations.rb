require_relative 'helper'

describe Mongol::Associations do

  describe "many" do
    it "must have a many method" do
      Book.must_respond_to :many
    end

    it "must return an array like thing" do
      @book = Book.new
      @book.authors.must_respond_to :each
    end

    it "must accept an array" do
      @book = Book.new
      @book.authors = [Author.create]
      @book.authors.size.must_equal 1
    end

    it "must save the array" do
      @book = Book.new
      @book.authors = [Author.create]
      @book.save
      Book.last.authors.size.must_equal 1
    end

    it "must save the items in the array" do
      @book = Book.new
      @book.authors = [Author.new]
      @book.save
      Book.last.authors.first.must_be_kind_of Author
    end

    it "must allow adding to the array with <<" do
      @book = Book.new
      @book.authors << Author.create
      @book.save
      Book.last.authors.first.must_be_kind_of Author
    end

    it "must allow adding to the array with << then saving the items in the array" do
      @book = Book.new
      @book.authors << Author.new
      @book.save
      Book.last.authors.first.must_be_kind_of Author
    end
  end

  describe "from" do
    it "must find the parent that it is associated with" do
      @book = Book.new
      @book.authors = [Author.new]
      @book.save
      Author.first.book.id.must_equal @book.id
    end

    it "must save the related parent" do
      @author = Author.create
      @author.book = Book.new
      @author.save
      Book.last.id.must_equal @author.book.id
    end

    it "must save the related parent even if it's not saved" do
      @author = Author.new
      @author.book = Book.new
      pp @author
      @author.save
      pp @author
      # pp Book.last
      # pp Author.last
      Book.last.id.must_equal Author.last.book.id
    end
  end

end
