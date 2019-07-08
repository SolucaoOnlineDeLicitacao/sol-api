module BaseNotificationsController
  extend ActiveSupport::Concern

  include CrudController

  included do
    load_and_authorize_resource

    before_action :update_read_at, only: :mark_as_read

    expose :notifications, -> { find_notifications }
    expose :notification
  end

  def index
    paginate json: paginated_resources, each_serializer: NotificationSerializer
  end

  def mark_as_read
    head :ok
  end

  def unreads_count
    render json: { count: notifications.where(read_at: nil).count }
  end

  private

  def update_read_at
    # we just updates de read_at (wont need to trigger callbacks etc)
    notification.update_column(:read_at, DateTime.now) unless notification.read_at?
  end

  def resource
    notification
  end

  def resources
    notifications
  end

  def find_notifications
    return current_notifications.unreads if received_unreads_param?

    current_notifications
  end

  def received_unreads_param?
    params[:unreads].present?
  end

  def default_sort_scope
    # we wont search notification
    resources
  end

  def current_notifications
    Notification.accessible_by(current_ability).by_receivable(current_user)
  end
end
