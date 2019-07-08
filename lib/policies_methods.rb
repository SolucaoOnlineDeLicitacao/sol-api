# frozen_string_literal: true

module Policies
  module Bidding; end
  module Proposal; end
  module LotProposal; end
end

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'policies', 'bidding', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'policies', 'proposal', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'policies', 'lot_proposal', '*.rb')]
  .sort.each { |f| require_dependency f }
