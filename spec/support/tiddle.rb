module TiddleTokenAuthenticationHelper

  def token_sign_in(resource)
    token = Tiddle.create_and_return_token(resource, request)
    model_name = Tiddle::ModelName.new.with_underscores(resource)

    # adding authentication headers
    request.headers.merge! "X-#{model_name}-EMAIL" => resource.email,
                           "X-#{model_name}-TOKEN" => token
  end

  def token_sign_out(resource)
    model_name = Tiddle::ModelName.new.with_underscores(resource)

    # erasing authentication headers
    request.headers.merge! "X-#{model_name}-EMAIL" => '',
                           "X-#{model_name}-TOKEN" => ''
  end

end

RSpec.configure do |config|
  config.include TiddleTokenAuthenticationHelper, type: :controller
end
