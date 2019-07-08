# Capistrano passenger tasks
namespace :passenger do

  desc "Restarts Passenger (and the app)"
  task :restart do
    on roles(:web) do
      within release_path do
        execute :touch, 'tmp/restart.txt'
      end
    end
  end

  desc "Bootstrap app load after Passenger restart (restart.txt method)"
  task :bootstrap do
    on roles(:web) do |host|
      run_locally do
        system "curl --silent --location #{host.hostname}"
      end
    end
  end
end


namespace :load do
  task :defaults do
    # auto hooking after publishing if PASSENGER_RESTART ENV var allows
    if ENV.fetch('PASSENGER_RESTART', 'yes').to_s.downcase == 'yes'
      after :'deploy:publishing', :'passenger:restart'
      after :'passenger:restart', :'passenger:bootstrap'
    end
  end
end
