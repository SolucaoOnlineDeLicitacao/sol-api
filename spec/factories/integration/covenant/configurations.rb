FactoryBot.define do
  factory :integration_covenant_configuration, parent: :integration_configuration, class: 'Integration::Covenant::Configuration' do
    type 'Integration::Covenant::Configuration'
    sequence(:endpoint_url) { |s| "http://integracao.rn.org.br/covenants#{s}" }
  end
end
