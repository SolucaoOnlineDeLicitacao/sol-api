# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "sdc-api"
set :repo_url, "https://github.com/car-bahia/sol-api.git"

# Default branch is :master
if ENV['BRANCH']
  set :branch, ENV['BRANCH']
else
  ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
end

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, -> { fetch(:stage_deploy_to, "/app/#{fetch(:application)}/#{fetch(:stage)}") }

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, *%w[
  config/cable.yml
  config/database.yml
  config/secrets.yml
  config/sidekiq.yml
  config/storage.yml
  config/newrelic.yml
  public/robots.txt
]

# Default value for linked_dirs is []
append :linked_dirs, *%w[
  log
  node_modules
  public/system
  public/storage
  public/uploads
  tmp/cache
  tmp/pids
  tmp/sockets
  storage
]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# setting RAILS_ENV (i.e. rake db:mgirate)
set :rails_env, 'production'

