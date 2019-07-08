# frozen_string_literal: true

module ApiIntegration; end

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'api_integration', '*.rb')]
  .sort.each { |f| require_dependency f }

module ApiBlockchain; end

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'api_blockchain', '*.rb')]
  .sort.each { |f| require_dependency f }

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'api_blockchain', 'response', '*.rb')]
  .sort.each { |f| require_dependency f }
