#
# Helper tasks to control logging.
#
# usage:
# ```bash
#   # normal task logging
#   bundle exec rake some:special:task
#
#   # logging to STDOUT
#   bundle exec rake verbose some:special:task
#
#   # logging DEBUG level to STDOUT
#   bundle exec rake debug some:special:task
# ```
#
# ref: http://macbury.ninja/2014/8/better-loging-in-rake-tasks
#

desc "Switch Rails and ActiveRecord logger to STDOUT"
task verbose: :environment do
  Rails.logger = Logger.new(STDOUT, level: :info)
  ActiveRecord::Base.logger = Logger.new(STDOUT, level: :info)
end

desc "Switch Rails and ActiveRecord logger level to DEBUG on STDOUT"
task debug: :verbose do
  Rails.logger.level = Logger::DEBUG
  ActiveRecord::Base.logger.level = Logger::DEBUG
end
