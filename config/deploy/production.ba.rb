server "10.70.0.46", user: "sol", roles: %w{app db web sidekiq} # api.sol.car.ba.gov.br
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :application, "sol-api"
set :stage, 'production'
