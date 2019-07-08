RSpec::Matchers.define :include_error_key_for do |field, key|
  match do |actual|
    actual.valid?
    actual.errors.added? field.to_sym, key.to_sym
  end

  failure_message do |actual|
    "expected that #{field} would include error for #{key}. Errors: #{actual.errors.details}"
  end
end
