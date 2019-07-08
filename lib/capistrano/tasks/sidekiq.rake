# Sidekiq tasks
namespace :sidekiq do
  %i(status start stop restart).each do |action|
    desc "#{action} Sidekiq service"
    task action do
      on roles(:sidekiq) do
        execute :sudo, "systemctl #{action} #{fetch(:sidekiq_service)}",
          raise_on_non_zero_exit: (action != :status)
      end
    end
  end
end


namespace :load do
  task :defaults do
    set :sidekiq_service, "sidekiq.service"

    # auto hooking after publishing if SIDEKIQ_RESTART ENV var allows
    if ENV.fetch('SIDEKIQ_RESTART', 'yes').to_s.downcase == 'yes'
      after :'deploy:publishing', :'sidekiq:restart'
    end
  end
end
