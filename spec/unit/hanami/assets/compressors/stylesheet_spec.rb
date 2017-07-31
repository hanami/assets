require 'hanami/assets/compressors/stylesheet'
require 'hanami/foo/compressor'

describe Hanami::Assets::Compressors::Stylesheet do
  describe '.for' do
    let(:compressor) { Hanami::Assets::Compressors::Stylesheet.for(engine_name) }

    describe 'when given argument is nil' do
      let(:engine_name) { nil }

      it 'returns NullCompressor' do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::NullCompressor)
      end
    end

    describe 'when given argument is :yui' do
      let(:engine_name) { :yui }

      it 'returns YuiStylesheet' do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::YuiStylesheet)
      end
    end

    describe 'when given argument is :sass' do
      let(:engine_name) { :sass }

      it 'returns SassStylesheet' do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::SassStylesheet)
      end
    end

    describe 'when given argument is unknown symbol' do
      let(:engine_name) { :wat }

      it 'raises error' do
        expect { compressor }.to raise_error(Hanami::Assets::Compressors::UnknownCompressorError,
                                             'Unknown Stylesheet compressor: :wat')
      end
    end

    describe 'when third party gem' do
      let(:engine_name) { :foo }

      it 'returns FooStylesheet' do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::FooStylesheet)
      end
    end

    describe 'when anything else' do
      let(:engine_name) { CustomStylesheetCompressor.new }

      it 'is returned as it is' do
        expect(compressor).to eq(engine_name)
      end
    end
  end
end
