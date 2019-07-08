module ControllerHelpers
  def format_json(serializer, resource, options = {})
    if options.present?
      if has_scope_key?(options)
        return JSON.parse(serializer.new(resource, options).serializable_hash.to_json)
      end

      return JSON.parse(serializer.new(resource).serializable_hash(options).to_json)
    end

    JSON.parse(serializer.new(resource).serializable_hash.to_json)
  end

  def has_scope_key?(options)
    options.keys.size == 1 && options.keys.first == :scope
  end

  # Instead of use simple `subject { controller.send(resource_name).versions.last }`
  # with this logic we can use `bidding.event_cancellation_requests` for example
  # => it_behaves_like 'a version of', 'post_update', 'bidding.event_cancellation_requests'
  def version_resource(resource_name)
    commands = resource_name.split('.')

    result = nil

    commands.map do |command|
      if result
        result = result.send(command)
      else
        result = controller.send(command)
      end
    end

    return result.first if result.is_a?(ActiveRecord::Associations::CollectionProxy)

    result
  end
end
