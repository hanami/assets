require 'test_helper'

describe Lotus::Assets do
  describe '.sources' do
    before do
      Lotus::Assets.sources.clear
    end

    after do
      Lotus::Assets.sources.clear
    end

    it "it's empty by default" do
      Lotus::Assets.sources.must_be :empty?
    end

    it "allows to add a source" do
      Lotus::Assets.sources << __dir__

      assert Lotus::Assets.sources == [ __dir__ ],
        "Expected Lotus::Assets.sources to eq [#{ __dir__ }], got: #{ Lotus::Assets.sources.inspect }"
    end

    it "adds a source to the configuration" do
      Lotus::Assets.sources << __dir__
      Lotus::Assets.configuration.sources.must_include __dir__
    end

    it "keeps duplicated frameworks in sync" do
      source = __dir__ + '/fixtures/bookshelf/vendor/assets' + '/fixtures/bookshelf/vendor/assets'
      Lotus::Assets.sources << source

      Lotus::Assets.duplicates.map(&:configuration).each do |config|
        config.sources.must_include source
      end
    end
  end
end
