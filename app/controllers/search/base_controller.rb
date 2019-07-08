module Search
  class BaseController < ApplicationController
    before_action :auth!

    def index
      render json: SearchService::Base.call(params, base_resources, serializer)
    end

    private

    def serializer_klass; end

    def serializer
      serializer_klass if serialized?
    end

    def serialized?
      ActiveModel::Type::Boolean.new.cast(params.fetch(:serialized, false))
    end

    def base_resources; end

    def auth!
      doorkeeper_authorize! :admin
    end
  end
end
