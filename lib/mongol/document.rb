require_relative 'document/query'
require_relative 'document/timestamps'
require_relative 'document/associations'

module Mongol
  module Document
    extend ActiveSupport::Concern

    module InstanceMethods
      def initialize(new_attributes = {})
        self.attributes = new_attributes.is_a?(Hash) ? new_attributes.symbolize_keys : {}
        dup_original_attributes
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
        self.attributes[:_id] = new_id
      end

      def new_document?
        id.nil?
      end
      def saved? # rename this persisted?
        !new_document?
      end

      def dirty?
        new_document? || attributes != @original_attributes
      end
      def not_dirty?
        !dirty?
      end

      def savable?
        dirty? && not_being_saved?
      end

      def being_saved?
        @being_saved
      end
      def not_being_saved?
        !being_saved?
      end

    private
      def dup_original_attributes
        @original_attributes = attributes.dup
      end
    public

      def save
        @being_saved = true # this would work better with an Identity Map

        save_many_associations || ( return false ) # this will cause an infinite loop

        save_result = if (new_document?)
          # puts attributes
          new_id = self.class.collection.insert(attributes)
          if new_id
            self.id = new_id
            dup_original_attributes
          end
          !!new_id
        else
          result = !!self.class.collection.update({'_id' => id}, attributes)
          dup_original_attributes if result
          result
        end

        save_from_associations || ( return false )

        @being_saved = false

        save_result
      end

      def save_many_associations
        self.class.associations.select { |ass| ass[:type] == :many }.map do |ass|
          self.send(:"#{ass[:name]}_relationship").save
        end.all?
      end

      def save_from_associations
        self.class.associations.select { |ass| ass[:type] == :from }.map do |ass|
          self.send(:"#{ass[:name]}_relationship").save
        end.all?
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
      include Mongol::Query
      include Mongol::Timestamps
      include Mongol::Associations

      def collection
        @collection ||= Mongol.database[self.name.tableize]
      end

      # Just a simple array of hashes for now
      def associations
        @associations ||= []
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
