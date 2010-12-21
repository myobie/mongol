require_relative 'document/query'

module Mongol
  module Document
    extend ActiveSupport::Concern

    module InstanceMethods
      def initialize(new_attributes = {})
        self.attributes = new_attributes.symbolize_keys || {}
      end

      def attributes
        @attributes ||= {}
      end
      def attributes=(new_attributes)
        @attributes = new_attributes.symbolize_keys if new_attributes.is_a? Hash
      end

      def [](attribute_name)
        attributes[attribute_name.to_sym]
      end
      def []=(attribute_name, new_value)
        attributes[attribute_name.to_sym] = new_value
      end

      def id
        attributes[:_id]
      end
      def id=(new_id)
        attributes[:_id] = new_id
      end

      def new_document?
        id.nil?
      end
      def saved?
        !new_document?
      end

      def save
        if (new_document?)
          new_id = self.class.collection.insert(attributes)
          self.id = new_id if new_id
          !!new_id
        else
          !!self.class.collection.update({'_id' => id}, attributes)
        end
      end

      def update(new_attributes)
        self.update_attributes(new_attributes)
        save
      end

      def update_attributes(new_attributes)
        self.attributes = attributes.merge(new_attributes)
      end

      def destroy
        self.class.collection.remove({'_id' => id})
        @_destroyed = true
      end
      def destroyed?
        !!@_destroyed
      end

      def ==(other)
        other.is_a?(self.class) && id.present? && other.id.present? && other.id == id
      end

    end

    module ClassMethods
      include Mongol::QueryStuff

      def collection
        @collection ||= Mongol.database[self.name.tableize]
      end

      def create(new_attributes = {})
        u = self.new(new_attributes)
        u.save
        u
      end

      def index(new_index, direction = Mongo::ASCENDING)
        collection.ensure_index([[new_index.to_s, direction]])
      end

      def drop_indexes
        collection.drop_indexes
      end

      def materialize(attributes = {})
        if attributes.is_a? Array
          attributes.map { |doc| materialize(doc) }
        else
          new(attributes)
        end
      end

    end

  end
end
