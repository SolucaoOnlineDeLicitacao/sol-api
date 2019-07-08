class NotificationSerializer < ActiveModel::Serializer

  attributes :id, :action, :created_at, :read_at, :title, :body, :notifiable_id, :args

  def args
    object.extra_args
  end

  def title
    I18n.t("#{key}.title") % object.title_args
  end

  def body
    I18n.t("#{key}.body") % object.body_args
  end

  def read_at
    object.read_at.rfc2822 if object.read_at
  end

  def created_at
    object.created_at.rfc2822 if object.created_at
  end

  private

  def key
    "notifications.#{object.action}"
  end
end
