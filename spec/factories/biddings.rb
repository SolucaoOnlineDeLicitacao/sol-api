FactoryBot.define do
  factory :bidding do
    sequence(:title) { |t| "Materiais #{t}" }
    description "Escola Pedro Barroso 2018 materiais de escritório para dieversas secretarias."
    covenant
    classification
    kind 2
    status 1
    deadline { rand(20..60) }
    link "https://www.gover.no/edital"
    start_date { Date.tomorrow }
    closing_date { Date.tomorrow+1.month }
    modality 0
    draw_end_days 10
    address 'address'

    transient do
      build_lot { true }
      build_invite { false }
    end

    after :build do |object, eval|
      object.lots << build(:lot, bidding: object) if eval.build_lot
      object.invites << build(:invite, bidding: object) if eval.build_invite
    end

    trait :with_invite do
      after :create do |object|
        create(:invite, bidding: object)
      end
    end

    trait :with_invites do
      after :create do |object|
        create_list(:invite, 3, bidding: object)
      end
    end

    trait :with_pending_invites do
      after :create do |object|
        create_list(:invite, 3, bidding: object, status: :pending)
      end
    end

    trait :invalid do
      title nil
      covenant nil
      start_date nil
      closing_date nil
      opening_date nil
    end
  end
end
