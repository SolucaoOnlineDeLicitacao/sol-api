server "10.1.3.52", user: "sol", roles: %w{app db web sidekiq} # api.sol.rn.gov.br
set :sidekiq_service, 'production.sol-api.sidekiq.service'
set :application, "sol-api"
set :stage, 'production'
