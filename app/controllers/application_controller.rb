class ApplicationController < ActionController::API
  include AbstractController::Translation

  before_action :set_locale

  def set_locale
    I18n.locale = current_user.try(:locale) || locale_from_params || I18n.default_locale
  end

  def current_user
    return nil unless doorkeeper_token

    @current_user ||= Doorkeeper::Extensions::ResourceOwnerFromTokenCommand.call doorkeeper_token
  end

  def current_ability
    @current_ability ||= Abilities::Strategy.call(user: current_user)
  end

  private

  # doorkeeper
  # --


  # Customizing response when unauthorized, based on doorkeeper authentication
  # passed to `render *options`
  # @see https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-the-response-body-when-unauthorized
  def doorkeeper_unauthorized_render_options(error:, **options)
    # doorkeeper adds http status :unauthorized
    { json: { error: error.name || :unauthorized } }
  end

  # Customizing response when forbidden, based on doorkeeper scopes
  # passed to `render *options`
  def doorkeeper_forbidden_render_options(error:, **options)
    # doorkeeper adds http status :forbidden
    { json: { error: error.name || :forbidden } }
  end

  def locale_from_params
    return params[:locale] if I18n.available_locales.map(&:to_s).include?(params[:locale])
  end
end
