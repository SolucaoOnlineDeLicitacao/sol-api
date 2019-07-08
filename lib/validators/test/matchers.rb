require 'rspec/matchers'

module Validators
  module Test
    #
    # Provê facilidades para implementação de testes (RSpec).
    #
    # Sugere-se seu emprego com um arquivo `spec/support/finder.rb`, contendo:
    # ```
    # RSpec.configure do |config|
    #   Validators::Test::Matchers.all.each do |validator|
    #     config.include validator, type: :model
    #   end
    # end
    # ```
    module Matchers
      def self.all
        constants.map do |const_name|
          constant = const_get(const_name)
          constant.is_a?(Module) ? constant : nil
        end.compact
      end
    end

  end
end


# requiring matchers
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'matchers', '**', '*.rb')]
  .sort.each { |f| require f }
