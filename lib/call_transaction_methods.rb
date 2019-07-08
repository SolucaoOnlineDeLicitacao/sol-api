# frozen_string_literal: true

module CallTranscationMethods; end

require_dependency 'transaction_methods'

# auto requiring call methods
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'call', '*.rb')]
  .sort.each { |f| require_dependency f }
