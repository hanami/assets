require 'hanami/assets/cache'

RSpec.describe Hanami::Assets::Cache do
  let(:cache) { Hanami::Assets::Cache.new }

  describe '#modified?' do
    it "returns false when the stored file wasn't updated" do
      file = TestFile.new
      cache.store(file)

      expect(cache.modified?(file)).not_to eq(true)
    end

    it 'returns true when the file was updated after the last check' do
      file = TestFile.new
      cache.store(file)

      file.touch do
        expect(cache.modified?(file)).to eq(true)
      end
    end

    it 'returns true when the file was never stored' do
      file = TestFile.new

      expect(cache.modified?(file)).to eq(true)
    end

    describe 'with dependencies' do
      it "returns true when both file and deps weren't updated, but checking at the same timestamp" do
        file =  TestFile.new
        deps = [TestFile.new]

        cache.store(file, deps)
        expect(cache.modified?(file)).to eq(true)
      end

      it 'returns true when at least one dependency was updated' do
        file =        TestFile.new
        deps = [dep = TestFile.new]

        cache.store(file, deps)

        dep.touch do
          expect(cache.modified?(file)).to eq(true)
        end
      end
    end
  end
end
