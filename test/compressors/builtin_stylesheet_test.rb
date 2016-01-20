require 'test_helper'
require 'hanami/assets/compressors/builtin_stylesheet'

describe Hanami::Assets::Compressors::BuiltinStylesheet do
  let(:compressor) { Hanami::Assets::Compressors::BuiltinStylesheet.new }

  describe '#compress' do
    it 'compresses given file' do
      asset    = __dir__ + '/../fixtures/reset.css'
      expected = File.read(__dir__ + '/../fixtures/compressed-reset.css')
      actual   = compressor.compress(asset)

      actual.must_equal(expected)
    end
  end
end
