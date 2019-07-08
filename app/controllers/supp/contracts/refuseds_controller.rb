module Supp
  class Contracts::RefusedsController < SuppController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    expose :contract

    before_action :set_paper_trail_whodunnit

    def update
      if updated?
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event.errors_as_json }
      end
    end

    private

    def resource
      contract
    end

    def updated?
      service.call
    end

    def service
      @service ||= ContractsService::Refused.new(service_params)
    end

    def event
      @event ||= event_service.event
    end

    def event_service
      @event_service ||= service.event_service
    end

    def service_params
      {
        contract: contract,
        comment: params[:comment],
        refused_by: current_user
      }
    end
  end
end
