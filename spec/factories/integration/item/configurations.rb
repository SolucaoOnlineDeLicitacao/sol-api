FactoryBot.define do
  factory :integration_item_configuration, parent: :integration_configuration, class: 'Integration::Item::Configuration' do
    type 'Integration::Item::Configuration'
    sequence(:endpoint_url) { |s| "http://integracao.rn.org.br/items#{s}" }
  end
end
