FactoryBot.define do
  factory :oauth_application, class: Doorkeeper::Application do
    sequence(:name) { |n| "Application #{n}" }
    sequence(:secret) { |n| "secret-app-#{n}" }

    redirect_uri 'https://example.com/callback'
    scopes 'user'
  end
end
