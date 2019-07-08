module CurrentEventCancellable
  def comment_response
    current_event&.comment_response
  end

  def current_event
    event_resource.event_cancellation_requests&.changing_to('canceled')&.last
  end
end
