# frozen_string_literal: true

module Importers; end

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'importers', '*.rb')]
  .sort.each { |f| require_dependency f }
