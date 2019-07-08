module Supp::Biddings::Lots
  class LotProposalImportsController < SuppController
    include ImportsController

    load_and_authorize_resource :bidding
    load_and_authorize_resource :lot
    load_and_authorize_resource :lot_proposal_import, through: [:bidding, :lot], except: :create

    private

    def service_async_call
      BiddingsService::LotProposalImports::Create.async_call(service_params)
    end

    def service_params
      {
        lot_proposal_import: lot_proposal_import,
        lot: lot,
        user: current_user,
        bidding: bidding
      }
    end
  end
end
