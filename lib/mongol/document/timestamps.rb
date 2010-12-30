module Mongol
  module Timestamps

    def timestamps!
      @_track_timestamps = true
      include Mongol::Timestamps::TimestampMethods
    end

    module TimestampMethods
      def save
        attributes[:created_at] = Time.now if attributes[:created_at].blank?
        attributes[:updated_at] = Time.now
        super
      end
    end

  end
end
