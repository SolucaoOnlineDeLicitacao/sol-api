require 'rspec/expectations'

module BeVersionableSupportMatcher
  extend RSpec::Matchers::DSL

  #
  #  Checks the proper use of Versionable concern.
  #
  #  Given that User < ApplicationRecord
  #
  #  ```
  #  it { is_expected.to be_versionable }
  #  ```
  #
  matcher :be_versionable do

    match do |actual|
      # can't use be matcher because we're defining `be_versionable`!
      expect(Versionable.models).to include actual.class

      # PaperTrail testing
      with_versioning do
        expect(actual).to be_versioned
      end
    end

  end

end


RSpec.configure do |config|
  config.include BeVersionableSupportMatcher, type: :model
end

