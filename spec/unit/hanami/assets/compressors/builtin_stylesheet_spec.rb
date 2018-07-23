require 'hanami/assets/compressors/builtin_stylesheet'

RSpec.describe Hanami::Assets::Compressors::BuiltinStylesheet do
  let(:compressor) { Hanami::Assets::Compressors::BuiltinStylesheet.new }

  describe '#compress' do
    it 'compresses given file' do
      asset    = __dir__ + "/../../../../support/fixtures/reset.css"
      expected = File.read(__dir__ + '/../../../../support/fixtures/compressed-reset.css')
      actual   = compressor.compress(asset)

      expect(actual).to eq(expected)
    end
  end
end
