module UploadWorker
  class << self
    def included(klass)
      klass.send(:include, Sidekiq::Worker)
      klass.send(:sidekiq_options, queue: queue_name('default'), retry: 5)

      create_perform_method(klass)
    end

    def create_perform_method(klass)
      model = model(klass)
      notification_class, notification_type = notification(klass)

      klass.class_eval do
        define_method :perform do |user_id, import_id|
          BiddingsService::Upload.call(
            user_id: user_id,
            import_model: model,
            import_id: import_id,
            notification_class: notification_class,
            notification_type: notification_type
          )
        end
      end
    end

    def queue_name(klass)
      klass.to_s.remove('Worker').underscore
    end

    def model(klass)
      "#{klass.to_s.remove('UploadWorker')}Import".constantize
    end

    def notification(klass)
      lot_name = "#{klass.to_s.remove('ProposalUploadWorker')}"

      return lot_notification_resource(lot_name) if lot_name.present?

      notification_resource
    end

    def lot_notification_resource(lot_name)
      ["Notifications::ProposalImports::#{lot_name}".pluralize, 'lot_']
    end

    def notification_resource
      ["Notifications::ProposalImports", nil]
    end
  end
end
