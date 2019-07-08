require_dependency 'validators/test/matchers'

RSpec.configure do |config|
  Validators::Test::Matchers.all.each do |validator|
    config.include validator, type: :model
  end
end
