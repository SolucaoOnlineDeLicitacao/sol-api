FactoryBot.define do
  factory :device_token do
    association :owner, factory: :user
    body "MrdkRuRQFwNI5u8Dh0cI90ABD3BOKnxkEla8cGdisbDHl5cVIkZah5QUhSAxzx4Roa7b4xy9tvx9iNSYw"
  end
end
