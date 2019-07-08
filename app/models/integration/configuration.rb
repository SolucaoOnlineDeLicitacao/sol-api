module Integration
  class Configuration < ApplicationRecord
    versionable

    enum status: %i[queued in_progress success fail], _prefix: true

    after_commit :update_crontab

    validates :type,
              :endpoint_url,
              :token,
              presence: true

    validates :schedule, cron_syntax: true

    validates_uniqueness_of :endpoint_url, case_sensitive: false

    def self.integrated?
      count > 0
    end

    private

    def update_crontab
      if changing_schedule?
        self.class.execute_whenever
      end
    end

    def changing_schedule?
      current_version &&
        current_version.event == 'update' &&
        current_version.object_changes.has_key?('schedule')
    end

    def current_version
      versions.last
    end

    def self.execute_whenever
      %x{ RAILS_ENV=#{Rails.env} bundle exec whenever --clear-crontab }
      %x{ RAILS_ENV=#{Rails.env} bundle exec whenever --update-crontab sol }
    end
  end
end
