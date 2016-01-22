require 'test_helper'

describe Hanami::Assets do
  describe '.sources' do
    before do
      Hanami::Assets.sources.clear
    end

    after do
      Hanami::Assets.sources.clear
    end

    it "it's empty by default" do
      Hanami::Assets.sources.must_be :empty?
    end

    it "allows to add a source" do
      Hanami::Assets.sources << __dir__

      assert Hanami::Assets.sources == [ __dir__ ],
        "Expected Hanami::Assets.sources to eq [#{ __dir__ }], got: #{ Hanami::Assets.sources.inspect }"
    end

    it "adds a source to the configuration" do
      Hanami::Assets.sources << __dir__
      Hanami::Assets.configuration.sources.must_include __dir__
    end

    it "keeps duplicated frameworks in sync" do
      source = __dir__ + '/fixtures/bookshelf/vendor/assets' + '/fixtures/bookshelf/vendor/assets'
      Hanami::Assets.sources << source

      Hanami::Assets.duplicates.map(&:configuration).each do |config|
        config.sources.must_include source
      end
    end
  end
end
