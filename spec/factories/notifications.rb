FactoryBot.define do
  factory :notification do
    association :receivable, factory: :supplier
    association :notifiable, factory: :bidding
    read_at nil
    action "new"
  end
end
