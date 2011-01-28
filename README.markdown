# This isn't finished yet.

I am only testing on Ruby 1.9.2 and I make lots of use of the new Hash syntax.

The things that work:

- Models
- Attributes
- Indexes
- Saving
- Querying (uses Plucky)
- Many associations (field is an array of id's of another model)
- From associations (reverse many)

What doesn't work now, but should eventually:

- One associations
- Many related associations (traditional has many)
- Belongs to associations
- Validations
- Embedded documents using models (so you can embed a Hash, just not
  another model yet)
- Identity Map
- Something else?

This list will be kept up to date.

# Examples

    class Book
      include Mongol::Document
      index :name
      index :isbn
      many :authors
    end

    class Author
      include Mongol::Document
      index :name
      from :book
    end

    # Things you can do:

    Book.where(name: "Moby Dick").limit(3).all

    Book.where(:name.in => ["Moby Dick", "Something Else"]).size

    # other query methods include: count, fields, skip, sort, exists?, each, paginate, get

    Book.first.authors.first

    b = Book.first
    b.authors = [Author.create, Author.new]
    b.authors << Author.create
    b.save # save's any unsaved authors

    a = Author.new
    a.book = Book.new
    a.save # save's book

    # Associations support all the same query methods as models
