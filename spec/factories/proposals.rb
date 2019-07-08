FactoryBot.define do
  factory :proposal do
    bidding
    provider
    status 0
    price_total { rand(5000..25000) }

    transient do
      build_lot_proposal { true }
    end

    transient do
      lot { }
    end

    after :build do |object, eval|
      lot = eval.lot || object.bidding.lots.first

      if eval.build_lot_proposal
        if lot.present?
          resource = build(:lot_proposal, proposal: object, lot: lot)
        else
          resource = build(:lot_proposal, proposal: object)
        end

        object.lot_proposals << resource
      end
    end

    trait :invalid do
      bidding nil
      provider nil
    end
  end
end
