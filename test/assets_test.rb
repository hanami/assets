require 'test_helper'

class FixtureClass
  include Lotus::Assets
end

describe Lotus::Assets do
  describe 'including Lotus::Assets' do
    it 'includes Lotus::Assets::Helpers into the base class' do
      FixtureClass.ancestors.must_include Lotus::Assets::Helpers
    end
  end
end
