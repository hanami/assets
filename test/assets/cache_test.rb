require 'test_helper'
require 'hanami/assets/cache'

describe Hanami::Assets::Cache do
  let(:cache) { Hanami::Assets::Cache.new }

  describe '#modified?' do
    it "returns false when the stored file wasn't updated" do
      file = TestFile.new
      cache.store(file)

      refute cache.modified?(file), "Expected #{file} to NOT be modified"
    end

    it 'returns true when the file was updated after the last check' do
      file = TestFile.new
      cache.store(file)

      file.touch do
        assert cache.modified?(file), "Expected #{file} to be modified"
      end
    end

    it 'returns true when the file was never stored' do
      file = TestFile.new

      assert cache.modified?(file), "Expected #{file} to be modified"
    end

    describe 'with dependencies' do
      it "returns false when both file and deps weren't updated" do
        file =  TestFile.new
        deps = [TestFile.new]

        cache.store(file, deps)
        refute cache.modified?(file), "Expected #{file} to NOT be modified"
      end

      it 'returns false when at least one dependency was updated' do
        file =        TestFile.new
        deps = [dep = TestFile.new]

        cache.store(file, deps)

        dep.touch do
          refute cache.modified?(file), "Expected #{file} to NOT be modified"
        end
      end
    end
  end
end
