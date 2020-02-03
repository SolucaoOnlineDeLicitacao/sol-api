module Dashboards
  class Admin
    NOTIFICATION_LIMIT = 2.freeze
    BOUNDS_DEFAULT = { south: 0.0, west: 0.0, north: 0.0, east: 0.0 }.freeze

    attr_accessor :bounds_params, :admin

    def initialize(admin:, bounds_params:)
      @admin = admin
      @bounds_params = bounds_params.present? ? bounds_params : BOUNDS_DEFAULT
    end

    def to_json
      return if bounds.invalid?

      {
        cooperatives_total: ::Cooperative.count,
        providers_total: ::Provider.count,
        ongoing_licitations_total: ::Bidding.in_progress_count,
        markers: markers,
        notifications: serialized_notifications
      }
    end

    private

    def bounds
      @bounds ||= ::Bound.new(bounds_params)
    end

    def markers
      markers = cooperatives.inject([]) do |array, cooperative|
        array << hash_marker(cooperative)
      end

      providers.inject(markers) do |array, provider|
        array << hash_marker(provider)
      end
    end

    def hash_marker(object)
      {
        position: position(object.address),
        id: object.id,
        text: object.name,
        title: object.name,
        type: object.class.base_class.to_s.downcase
      }
    end

    def position(address)
      {
        lat: address.latitude.to_f,
        lng: address.longitude.to_f
      }
    end

    def serialized_notifications
      latest_notifications.map do |notification|
        ::NotificationSerializer.new(notification)
      end
    end

    def latest_notifications
      user_notifications.sorted.limit(NOTIFICATION_LIMIT)
    end

    def user_notifications
      ::Notification.by_receivable(admin)
    end

    def cooperatives
      ::Cooperative.by_viewport(bounds).includes(:address)
    end

    def providers
      ::Provider.by_viewport(bounds).includes(:address)
    end
  end
end
