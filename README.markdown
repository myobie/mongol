# This isn't finished yet.

The things that work:

- Models
- Attributes
- Indexes
- Saving
- Querying (uses Plucky)
- Many associations

What doesn't work now, but should eventually:

- One associations
- Belongs to associations
- Validations
- Embedded documents
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
    end

    # Things you can do:

    Book.where(name: "Moby Dick").limit(3).all

    Book.where(:name.in => ["Moby Dick", "Something Else"]).size # also
    .count

    # other query methods include: fields, skip, sort, exists?, each, paginate, get

    Book.first.authors.first

    b = Book.first
    b.authors = [Author.create, Author.new]
    b.authors << Author.create
    b.save

    # Associations support all the same query methods as models
