describe Hanami::Assets do
  describe '.sources' do
    before do
      Hanami::Assets.sources.clear
    end

    after do
      Hanami::Assets.sources.clear
    end

    it "it's empty by default" do
      expect(Hanami::Assets.sources).to be_empty
    end

    it 'allows to add a source' do
      Hanami::Assets.sources << __dir__

      expect(Hanami::Assets.sources).to eq([__dir__])
    end

    it 'adds a source to the configuration' do
      Hanami::Assets.sources << __dir__
      expect(Hanami::Assets.configuration.sources).to include(__dir__)
    end

    it 'keeps duplicated frameworks in sync' do
      source = __dir__ + '/fixtures/bookshelf/vendor/assets' + '/fixtures/bookshelf/vendor/assets'
      Hanami::Assets.sources << source

      Hanami::Assets.duplicates.map(&:configuration).each do |config|
        expect(config.sources).to include(source)
      end
    end
  end
end
