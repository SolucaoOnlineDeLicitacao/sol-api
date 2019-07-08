# frozen_string_literal: true

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'spreadsheet', 'write', '*.rb')]
  .sort.each { |f| require_dependency f }
