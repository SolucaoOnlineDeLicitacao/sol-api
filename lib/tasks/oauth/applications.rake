require 'securerandom'

namespace :oauth do
  namespace :applications do

    desc 'Creating base OAuth Apps'
    task load: :environment do |task|
      Doorkeeper::Application.find_or_create_by!(name: 'sdc-cooperative-fronted.vue') do |app|
        app.attributes = {
          confidential: false, # it's a webapp! Also, confidential apps must authenticate when revoking tokens!
          uid: SecureRandom.hex(64),
          secret: SecureRandom.hex(64),
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scopes: 'user' # read write ...
        }
      end

      Doorkeeper::Application.find_or_create_by!(name: 'sdc-supplier-fronted.vue') do |app|
        app.attributes = {
          confidential: false, # it's a webapp! Also, confidential apps must authenticate when revoking tokens!
          uid: SecureRandom.hex(64),
          secret: SecureRandom.hex(64),
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scopes: 'supplier' # read write ...
        }
      end

      Doorkeeper::Application.find_or_create_by!(name: 'sdc-admin-frontend.vue') do |app|
        app.attributes = {
          confidential: false, # it's a webapp! Also, confidential apps must authenticate when revoking tokens!
          uid: SecureRandom.hex(64),
          secret: SecureRandom.hex(64),
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scopes: 'admin' # read write ...
        }
      end
    end
  end
end
