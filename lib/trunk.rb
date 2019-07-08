#
#   A manager for dumping and restoring postgres databases. Like an elephant uses
# it's trunk to handle the universe challenges.
#
#                _..--""-.                  .-""--.._
#           _.-'         \ __...----...__ /         '-._
#         .'      .:::...,'              ',...:::.      '.
#        (     .'``'''::;                  ;::'''``'.     )
#         \             '-)              (-'             /
#          \             /                \             /
#           \          .'.-.            .-.'.          /
#            \         | \0|            |0/ |         /
#            |          \  |   .-==-.   |  /          |
#             \          `/`;          ;`\`          /
#              '.._      (_ |  .-==-.  | _)      _..'
#                  `"`"-`/ `/'        '\` \`-"`"`
#                       / /`;   .==.   ;`\ \
#                 .---./_/   \  .==.  /   \ \
#                / '.    `-.__)       |    `"
#               | =(`-.        '==.   ;
#         jgs    \  '. `-.           /
#                 \_:_)   `"--.....-'
#
#
# usage:
#
#   Using rails config:
#
#   config = YAML.load_file(Rails.root.join('config', 'database.yml')[RAILS_ENV]
#
#
# ### dumping
#
#   trunk = Trunk.new file: dump_file,
#     username: config['username'],
#     host: config['host'],
#     database: config['database']
#
#   trunk.blow! # or trunk.dump!
#
#   logger.info "File '#{trunk.file}' successfully created."
#
#
# ### restoring
#
#   trunk = Trunk.new file: dump_to_be_restored,
#     username: config['username'],
#     host: config['host'],
#     database: config['database']
#
#   trunk.sniff! # or trunk.restore!
#
#   logger.info "Database '#{trunk.database}' successfully restored."
#
#
class Trunk
  attr_accessor :database, :file, :host, :username

  def initialize(**attributes)
    attributes.each_pair do |name, value|
      setter_method = "#{name}=".to_sym

      send setter_method, value if respond_to? setter_method
    end
  end


  def blow!
    if confirm?("Dumping database '#{database}' to '#{file}'. Are you sure?")
      system! <<~CMD.squeeze(' ').strip
        pg_dump --format=custom --file=#{file} \
          --no-owner --no-privileges \
          --username=#{username} --host=#{host} \
          #{database}
      CMD
    end
  end
  alias_method :dump!, :blow!

  def sniff!
    if confirm?("Restoring database '#{database}' with '#{file}'. Are you sure?")
      system! <<~CMD.squeeze(' ').strip
        pg_restore --format=custom \
          --exit-on-error --jobs=4 \
          --clean --if-exists \
          --no-owner --no-privileges \
          --username=#{username} --host=#{host} \
          --dbname=#{database} \
          #{file}
      CMD
    end
  end
  alias_method :restore!, :sniff!


  def file
    @file || "#{database}_from_#{hostname}_at_#{current_timestamp}.dump"
  end

  def host
    @host || 'localhost'
  end

  def rails_env
    @rails_env || 'development'
  end


  private

  def confirm?(message)
    print "#{message} [y/N]: "
    confirmed = gets.strip == 'y'

    abort 'aborted.' unless confirmed

    confirmed
  end

  def current_timestamp
    Time.now.strftime("%Y%m%d-%H%M%S")
  end

  def hostname
    `hostname`.strip
  end

  def system!(*args)
    system(*args) || abort("\nerror executing '#{args}'")
  end
end
