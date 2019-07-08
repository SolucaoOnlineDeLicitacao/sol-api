server "demo.api.sdc.caiena.net", user: "sdc", roles: %w{app db web sidekiq}
set :sidekiq_service, 'demo.sdc-api.sidekiq.service'
