require_relative 'helper'

describe Mongol::Timestamps do

  it "must have a timestamps! method" do
    Book.must_respond_to :timestamps!
  end

  it "wont track timestamps without being setup" do
    @book = Book.create
    @book[:created_at].must_be_nil
  end

  it "must set the created_at attribute upon save" do
    @book = BookWithTimestamps.create
    @book[:created_at].wont_be_nil
  end

  it "must set the updated_at attribute upon save" do
    @book = BookWithTimestamps.create
    @book[:updated_at].wont_be_nil
  end

  it "must set the updated_at attribute after every save" do
    @book = BookWithTimestamps.create
    @updated_at = @book[:updated_at]
    @book.save
    @book[:updated_at].must_be :>, @updated_at
  end

end
