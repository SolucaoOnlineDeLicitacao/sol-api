module Search
  class Register::ProvidersController < ApplicationController
    def index
      render json_response
    end

    private

    def json_response
      return { json: {}, status: :no_content } if term_match_with_provider_with_suppliers?

      { json: new_provider_json, status: :ok }
    end

    def term_match_with_provider_with_suppliers?
      Provider.with_suppliers.find_by(document: fetch_term).present?
    end

    def new_provider_json
      return {} unless new_provider.present?

      Administrator::ProviderSerializer.new(new_provider).
        serializable_hash.as_json.deep_stringify_keys
    end

    def new_provider
      @new_provider ||= Provider.all_without_users.find_by(document: fetch_term)
    end

    def fetch_term
      @fetch_term ||= params.fetch(:search, {}).fetch(:term, '')
    end
  end
end

