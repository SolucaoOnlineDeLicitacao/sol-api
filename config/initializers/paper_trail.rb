# config
PaperTrail.config.version_limit = 10
PaperTrail.config.track_associations = false

# We're using a custom Version model (app/models/audit.rb), in a custom table
# (audits). Therefore, we must let ActiveRecord know that PaperTrail::Version
# is an abstract class.
#   reference: https://github.com/airblade/paper_trail/blob/v5.2.0/README.md#configuration
module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    self.abstract_class = true
  end
end
