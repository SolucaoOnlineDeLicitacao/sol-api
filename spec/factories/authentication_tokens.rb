FactoryBot.define do
  factory :authentication_token do
    association :owner, factory: :user

    body "token-hash"
    last_used_at { DateTime.now.iso8601 }
    expires_in 1
    ip_address "MyString"
    user_agent "MyString"
  end
end
