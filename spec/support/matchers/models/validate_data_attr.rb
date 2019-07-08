require 'rspec/expectations'

module ModelValidateDataAttrSupportMatcher
  extend RSpec::Matchers::DSL

  matcher :define_data_attr do |field|
    match do |record|
      record = record

      record.send "#{field}=", 'value'

      record.send(:data)[field.to_s] == 'value' && record.send(field) == record.send(:data)[field.to_s]
    end

    description do
      "validate :#{field} as a json field on :data"
    end

    failure_message do
      <<-ERR.strip_heredoc
        expected field :#{field} to be stored on :data JSON attr
      ERR
    end
  end
end

RSpec.configure do |config|
  config.include ModelValidateDataAttrSupportMatcher, type: :model
end
