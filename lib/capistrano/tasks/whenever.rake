# Capistrano whenever tasks
namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    on roles(:web) do
      execute "cd #{release_path} && #{fetch :whenever_variables} #{fetch(:whenever_command)} #{fetch(:whenever_update_flags)}"
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    on roles(:web) do
      execute "cd #{release_path} && #{fetch(:whenever_command)} #{fetch(:whenever_clear_flags)}"
    end
  end

  before "deploy:publishing", "whenever:clear_crontab"
  after "deploy:symlink:release", "whenever:update_crontab"
end

namespace :load do
  task :defaults do
    set :whenever_command,      ->{ 'bundle exec whenever' }
    set :whenever_identifier,   ->{ fetch(:cron_user, 'sol') }
    set :whenever_environment,  ->{ fetch :rails_env, fetch(:stage, "production") }
    set :whenever_variables,    ->{ "RAILS_ENV=#{fetch :whenever_environment}" }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch(:whenever_identifier)}" }
  end
end
