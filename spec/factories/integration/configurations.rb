FactoryBot.define do
  factory :integration_configuration, class: 'Integration::Configuration' do
    sequence(:endpoint_url) { |s| "http://integracao.rn.org.br/cooperatives#{s}" }
    token "s3cr3t"
    schedule "0 14 * * *"
  end
end
