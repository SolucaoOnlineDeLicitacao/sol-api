class SearchService::Base

  attr_accessor :whitelisted_params
  attr_accessor :params

  LIMIT = 15.freeze

  def initialize(params, base_resources, serializer=nil)
    @params = params
    @base_resources = base_resources
    @serializer = serializer
  end

  def self.call(params, base_resources, serializer=nil)
    new(params, base_resources, serializer).call
  end

  def call
    search
  end

  private

  def search
    return resources.to_json(whitelisted_params) unless @serializer
    resources.map do |resource|
      @serializer.new(resource).serializable_hash.as_json.deep_stringify_keys
    end
  end

  def whitelisted_params
    { only: :id, methods: :text }
  end

  def fetch_term
    params.fetch(:search, {}).fetch(:term, '')
  end

  def resources
    @base_resources.search(fetch_term, self.class::LIMIT)
  end
end
