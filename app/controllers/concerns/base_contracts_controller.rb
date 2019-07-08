module BaseContractsController
  extend ActiveSupport::Concern

  include CrudController

  included do
    expose :contracts, -> { find_contracts }
    expose :contract
  end

  private

  def find_contracts; end

  def resource
    contract
  end

  def resources
    contracts
  end
end
