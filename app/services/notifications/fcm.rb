module Notifications
  class Fcm
    include TransactionMethods

    attr_accessor :notification

    delegate :receivable, :notifiable, :action, :title_args, :body_args,
             :extra_args, to: :notification

    def initialize(notification_id)
      @notification = Notification.find(notification_id)
    end

    def self.call(notification_id)
      new(notification_id).call
    end

    def call
      notify
    end

    private

    def notify
      return unless allowed_to_send?

      execute_or_rollback do
        @response = fcm.send(receivable_device_tokens, push_notification_attributes)
        destroy_not_registered_tokens!
      end
    end

    def allowed_to_send?
      receivable.respond_to?(:device_tokens)
    end

    def fcm
      @fcm ||= FCM.new(server_key)
    end

    def destroy_not_registered_tokens!
      # remove old tokens, without callbacks
      DeviceToken.where(body: not_registered_tokens).delete_all if not_registered_tokens.present?
    end

    def not_registered_tokens
      @response[:not_registered_ids]
    end

    def server_key
      @server_key ||= Rails.application.secrets.dig(:firebase, :server_key)
    end

    def receivable_device_tokens
      receivable.device_tokens.pluck(:body)
    end

    # Wont use the notification so it wont will be handled by
    # google server process
    # https://github.com/arnesson/cordova-plugin-firebase/issues/955#issuecomment-451302715
    # "notification": {
    #   title: locale_sanitize(:title, title_args),
    #   body: locale_sanitize(:body, body_args),
    # },
    def push_notification_attributes
      {
        "data": {
          title: locale_sanitize(:title, title_args),
          body: locale_sanitize(:body, body_args),
          id: @notification.id,
          action: action,
          notifiable_id: notifiable.id,
          args: extra_args
        }
      }
    end

    def locale_sanitize(key, args)
      sanitize(I18n.t("notifications.#{action}.#{key}") % args)
    end

    def sanitize(html)
      ActionView::Base.full_sanitizer.sanitize(html)
    end
  end
end
