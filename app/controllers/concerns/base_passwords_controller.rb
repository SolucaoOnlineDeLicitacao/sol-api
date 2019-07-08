module BasePasswordsController
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render status: :created, json: { success: true }
    else
      render status: :not_found, json: { errors: { "#{resource_class.name.downcase}": 'not_found' } }
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource_without_errors?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        resource.after_database_authentication
        sign_in(resource_name, resource)
      end
      update_access_tokens
      render status: :ok, json: { "#{resource_class.name.downcase}": resource }
    else
      set_minimum_password_length
      render status: :unprocessable_entity, json: { errors: resource.errors_as_json }
    end
  end

  def resource_without_errors?
    resource.errors.empty?
  end

  def update_access_tokens
    resource.access_tokens.update_all(revoked_at: DateTime.current)
  end
end
