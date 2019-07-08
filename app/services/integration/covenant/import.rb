require './lib/api_integration/client'
require './lib/api_integration/response'
require './lib/importers/covenant_importer'

# command?
module Integration
  class Covenant::Import
    include Integration::LogImporter

    attr_accessor :configuration

    def self.call
      new.call
    end

    def initialize
      # uses model configuration
      @configuration = Integration::Covenant::Configuration.last
      @client = ApiIntegration::Client.new
    end

    def call
      start!

      begin
        @configuration.status_fail! and return unless request.success?

        body.each do |resource|
          ::Importers::CovenantImporter.import(resource)
        end

        close_log

        @configuration.last_success_at = DateTime.current
        @configuration.status_success!

      rescue StandardError => e
        log(:error, I18n.t('services.importer.log.error', e: e.message))

        close_log
        @configuration.status_fail!
      end
    end

    private

    # connection

    def request
      @request ||= @client.request(
        endpoint: @configuration.endpoint_url,
        token: @configuration.token,
        params: request_params
      )
    end

    def request_params
      return {} unless @configuration.last_success_at.present?

      { updated_at: @configuration.last_success_at.strftime('%Y-%m-%d') }
    end

    def body
      @body ||= request.body
    end
  end
end
