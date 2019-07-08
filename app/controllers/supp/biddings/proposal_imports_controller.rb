module Supp::Biddings
  class ProposalImportsController < SuppController
    include ImportsController

    load_and_authorize_resource :bidding
    load_and_authorize_resource :proposal_import, through: :bidding, except: :create

    private

    def service_async_call
      BiddingsService::ProposalImports::Create.async_call(service_params)
    end

    def service_params
      {
        proposal_import: proposal_import,
        user: current_user,
        bidding: bidding
      }
    end
  end
end
