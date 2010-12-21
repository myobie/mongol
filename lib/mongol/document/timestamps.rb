module Mongol
  module Timestamps
    extend ActiveSupport::Concern

    module ClassMethods
      def timestamps!
        @_track_timestamps = true
      end
    end

    module InstanceMethods
      def save
        attributes[:created_at] = Time.now if attributes[:created_at].blank?
        attributes[:updated_at] = Time.now
        super
      end
    end

  end
end
