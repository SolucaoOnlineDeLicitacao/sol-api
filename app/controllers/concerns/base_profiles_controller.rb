module BaseProfilesController
  extend ActiveSupport::Concern
  include TransactionMethods

  PROFILE_PERMITTED_PARAMS = [
    :avatar, :password, :password_confirmation
  ].freeze

  def profile
    if update?
      render status: :ok, json: { "#{klass_sym}": profile_json }
    else
      render status: :unprocessable_entity, json: { errors: current_user.errors_as_json }
    end
  end

  private

  def update?
    execute_or_rollback do
      current_user.update!(profile_params)
      if params_with_password?
        current_user.access_tokens.map do |access_token|
          update_access_token!(access_token)
        end
      end
    end
  end

  def update_access_token!(token)
    token.update!(revoked_at: DateTime.current)
  end

  def klass_sym
    current_user.class.table_name.singularize
  end

  def profile_json
    base_profile_json.merge(profile_avatar_json)
  end

  def base_profile_json
    {
      'id'       => current_user.id,
      'name'     => current_user.name,
      'username' => current_user.email,
    }
  end

  def profile_avatar_json
    return {} if current_user.is_a? Admin
    { 'avatar' => { 'url' => current_user.avatar.url } }
  end

  def profile_params
    return received_params if params_with_password?
    received_params.except("password", "password_confirmation")
  end

  def received_params
    params.require(klass_sym).permit(*PROFILE_PERMITTED_PARAMS)
  end

  def params_with_password?
    params.dig(klass_sym, :password).present? ||
      params.dig(klass_sym, :password_confirmation).present?
  end

end
