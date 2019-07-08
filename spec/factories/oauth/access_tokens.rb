FactoryBot.define do
  factory :oauth_access_token, class: Doorkeeper::AccessToken do
    transient do
      resource_owner { create :user }
    end

    resource_owner_id { resource_owner.id }
    association :application, factory: :oauth_application
    expires_in 2.hours

    factory :clientless_access_token do
      application nil
    end
  end
end
