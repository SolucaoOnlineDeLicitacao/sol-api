FactoryBot.define do
  factory :integration_cooperative_configuration, parent: :integration_configuration, class: 'Integration::Cooperative::Configuration' do
    type 'Integration::Cooperative::Configuration'
    sequence(:endpoint_url) { |s| "http://integracao.rn.org.br/cooperatives#{s}" }
  end
end
