module BiddingsService
  class Upload
    include Call::Methods

    attr_accessor :user, :import

    def initialize(*args)
      super
      @user = Supplier.find_by(id: user_id)
      @import = import_model.find(import_id)
    end

    def main_method
      upload
    end

    private

    def upload
      import.processing!
      upload_all.call!
      import.success!
      notify('Success')
    rescue => err
      import.update!(error_message: err.message, error_backtrace: err.backtrace)
      import.error!
      notify('Error')
    end

    def upload_all
      BiddingsService::Upload::All::Strategy.decide(user: user, import: import)
    end

    def notify(type)
      "#{notification_class}::#{type}".constantize.send(
        :call, "#{notification_type}proposal_import": import, supplier: user
      )
    end
  end
end
