FactoryBot.define do
  factory :report do
    association :admin, factory: :admin
    report_type :biddings
    status :waiting
    url nil
    error_message nil
    error_backtrace nil
  end
end
