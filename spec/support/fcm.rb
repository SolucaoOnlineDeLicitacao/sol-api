# subbing all request when type :notification
RSpec.configure do |config|
  config.before(:each, type: :notification) do
    stub_request(:post, "https://fcm.googleapis.com/fcm/send").
      to_return(status: 200, body: "", headers: {})
  end
end
