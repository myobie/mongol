module Mongol
  module Associations
    extend ActiveSupport::Concern

    included do

    end

    def many(name, options = {})
      singular_name = name.to_s.singularize

      define_method name.to_sym do
        ass = instance_variable_get(:"@_#{name}_association")
        if ass
          ass
        else
          send(:"#{name}=", self[:"#{singular_name}_ids"])
        end
      end

      define_method :"#{name}_relationship" do
        self.send(name.to_sym)
      end

      define_method :"#{name}=" do |array|
        instance_variable_set(:"@_#{name}_association", AssociationArray.new(
          name: name,
          klass: options[:class] || name.to_s.singularize.classify.constantize,
          instance: self,
          max: options[:max],
          min: options[:min],
          ids: array
        ))
      end

      associations.push(type: :many, name: name)
    end

    def many_related(name, options = {})
    end

    def one(name, options = {})
    end

    def from(name, options = {})
      define_method name.to_sym do |opts = {}|
        ass = instance_variable_get(:"@_#{name}_association")
        rel_only = opts.delete(:relationship_only)
        if ass
          rel_only ? ass : ass.find_related
        else
          ass = instance_variable_set(:"@_#{name}_association", AssociationFromFinder.new(
            name: name,
            klass: options[:class] || name.to_s.classify.constantize,
            instance: self
          ))
          rel_only ? ass : ass.find_related
        end
      end

      define_method :"#{name}_relationship" do
        self.send(name.to_sym, relationship_only: true)
      end

      define_method :"#{name}=" do |item|
        send(:"#{name}_relationship").replace(item)
      end

      associations.push(type: :from, name: name)
    end

    def on(name, options = {})
    end

    #belongs_to
    class AssociationFromFinder

      def initialize(options = {})
        @options = options
        @name = options[:name]
        @klass = options[:klass]
        @instance = options[:instance]
        @related = nil
        @found = false
      end

      def find_related
        find_and_store_related if not_found?
        @related
      end

      def replace(what)
        @related = what
      end

      def save
        found? ? save_related : true
      end

      def found?
        !!@related
      end
      def not_found?
        !found?
      end

      def nil?
        @related === nil
      end
      def not_nil?
        !nil?
      end

    private
      def find_and_store_related
        field_name = :"#{@instance.class.collection.name.singularize}_ids"
        @related = @klass.where(field_name => @instance.id).first
      end

      def save_related
        @related.save if @related.savable?
      end

    end

    #one
    class AssociationItem

      def initialize(options = {})
        @options = options
        @name = options[:name]
        @singular_name = options[:name].to_s.singularize
        @klass = options[:klass]
        @instance = options[:instance]
        @max = options[:max] || 0
        @min = options[:min] || 0

        array = options[:ids] || []
        if array.first.is_a?(BSON::ObjectId)
          self.ids = array
        else
          self.ids = array.map { |doc| doc.saved? ? doc.id : doc }
        end
      end

    end

    #many
    class AssociationArray
      include Enumerable
      extend Forwardable

      def initialize(options = {})
        @options = options
        @name = options[:name]
        @singular_name = options[:name].to_s.singularize
        @klass = options[:klass]
        @instance = options[:instance]
        @max = options[:max] || 0
        @min = options[:min] || 0

        array = options[:ids] || []
        if array.first.is_a?(BSON::ObjectId)
          self.ids = array
        else
          self.ids = array.map { |doc| doc.saved? ? doc.id : doc }
        end
      end

      def ids
        @instance[:"#{singular_name}_ids"] ||= []
      end
      def ids=(new_array)
        @instance[:"#{singular_name}_ids"] = new_array
      end

      def collapse_ids
        self.ids = ids.map { |doc| doc.is_a?(BSON::ObjectId) ? doc : doc.id }
      end

      def only_saved_ids
        ids.select { |id| id.is_a?(BSON::ObjectId) }
      end

      def name
        @name
      end
      def singular_name
        @singular_name
      end

      # One can only query what is already saved
      def query
        @klass.where(:_id.in => only_saved_ids)
      end

      def_delegators :query, *Mongol::Query::ALL_METHODS

      def save
        ids.map do |doc|
          if !doc.is_a?(BSON::ObjectId) && doc.savable?
            doc.save
          else
            true # make sure things that don't need saving return true
          end
        end.all? && collapse_ids
      end

      def destroy
        all.map { |model| model.destroy }
        self.ids = []
        true
      end

      def <<(item)
        self.ids << item
      end

      def [](index)
        ids[index]
      end

      def []=(index, item)
        self.ids[index] = item
      end

      def replace(new_models)
        @models = nil
        self.ids = new_models.map { |model| model.id }
        self
      end

      def clear
        self.ids = []
        self
      end

      def eql?(other)
        other == self || other == all
      end

      def to_a
        ids
      end
      alias :to_ary :to_a

      def to_s
        ids.to_s
      end

      %w(push unshift).each do |m|
        define_method m.to_sym do |item|
          self.ids.send(m.to_sym, item)
        end
      end

      %w(pop shift).each do |m|
        define_method m.to_sym do
          self.ids.send(m.to_sym)
        end
      end

    end

  end
end
