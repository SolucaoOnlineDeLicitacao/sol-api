# frozen_string_literal: true

#
# CoreExtensions
#
# Provê extensões às classes do Ruby Core (stdlib).
# Ex:
#   - String#unaccent
#
module CoreExtensions; end

# If we need to require in order, we can do it explicitly
# require_relative 'core_extensions/string'

# auto requiring extensions
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'core_extensions', '*.rb')]
  .sort.each { |extension| require extension }
