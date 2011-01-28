module Mongol
  module Query
    extend ActiveSupport::Concern

    SELF_METHODS = %w(where fields limit skip sort count size exists? exist?)
    ARRAY_METHODS = %w(last first all each paginate get)
    ALL_METHODS = SELF_METHODS + ARRAY_METHODS

    module PluckyExtensions
      def model
        @model
      end
      def model=(new_model)
        @model = new_model
      end

      def get(id)
        find_one(id: id)
      end

      ARRAY_METHODS.each do |m|
        define_method m.to_sym do |*args, &block|
          results = super(*args, &block)
          results ? model.materialize(results) : results
        end
      end

    end

    included do
      extend Forwardable
      def_delegators :query, *ALL_METHODS
    end

    def query(options = {})
      Plucky::Query.new(collection).tap do |q|
        q.extend(PluckyExtensions)
        q.update(options)
        q.model = self
      end
    end

  end
end
