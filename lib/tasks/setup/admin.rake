# PASSWORD=passw EMAIL=meu@email.com bundle exec rake setup:admin:load

namespace :setup do
  namespace :admin do
    desc 'Create initial users. Requires PASSWORD and EMAIL env var to be set when creating users.'
    task load: :environment do |task|
      ensure_envs = -> do
        raise ArgumentError, 'EMAIL ou PASSWORD em branco' if ENV['PASSWORD'].blank? || ENV['EMAIL'].blank?
      end


      Admin.find_or_create_by!(email: ENV['EMAIL']) do |admin|
        ensure_envs.call

        admin.attributes = {
          name: 'Administrador SOL',
          password: ENV['PASSWORD'],
          password_confirmation: ENV['PASSWORD'],
          role: :general
        }
      end
    end
  end
end
