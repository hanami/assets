require 'hanami/assets/compressors/builtin_stylesheet'

describe Hanami::Assets::Compressors::BuiltinStylesheet do
  let(:compressor) { Hanami::Assets::Compressors::BuiltinStylesheet.new }

  describe '#compress' do
    it 'compresses given file' do
      asset    = __dir__ + '/../../../fixtures/reset.css'
      expected = File.read(__dir__ + '/../../../fixtures/compressed-reset.css')
      actual   = compressor.compress(asset)

      expect(actual).to eq(expected)
    end
  end
end
