module Mongol
  module QueryStuff
    extend ActiveSupport::Concern

    included do
      extend Forwardable
      def_delegators :query, :where, :fields, :limit, :skip, :sort, :count
    end

    def query(options = {})
      Plucky::Query.new(collection).tap do |q|
        q.update(options)
      end
    end

    %w(last first all paginate find exists? exist? find_each).each do |m|
      define_method m.to_sym do |options = {}|
        materialize(query(options).send(m.to_sym))
      end
    end

  end
end
