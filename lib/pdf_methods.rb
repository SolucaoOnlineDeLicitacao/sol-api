# frozen_string_literal: true

module Pdf
  module Bidding
    module Minute
      module Addendum
        class Base; end
      end
    end
    module Edict; end
  end
  module Contract
    module Classification; end
  end
end

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', 'contract', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', 'contract', '**', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', 'bidding', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', 'bidding', '**', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'pdf', 'builder', '*.rb')]
  .sort.each { |f| require_dependency f }