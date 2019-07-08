namespace :setup do
  namespace :integrations do
    desc 'Create initial integrations.'
    task load: :environment do |task|

      Integration::Configuration.find_or_create_by!(type: "Integration::Cooperative::Configuration") do |integration|
        integration.attributes = {
          endpoint_url: "http://ws/associacoes",
          token: "token",
          schedule: "2 5 * * 0",
          status: 'success'
        }
      end

      Integration::Configuration.find_or_create_by!(type: "Integration::Covenant::Configuration") do |integration|
        integration.attributes = {
          endpoint_url: "http://ws/convenios",
          token: "token",
          schedule: "2 5 * * 0",
          status: 'success'
        }
      end

      Integration::Configuration.find_or_create_by!(type: "Integration::Item::Configuration") do |integration|
        integration.attributes = {
          endpoint_url: "http://ws/itens",
          token: "token",
          schedule: "2 5 * * 0",
          status: 'success'
        }
      end
    end
  end
end
