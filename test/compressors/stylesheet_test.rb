require 'test_helper'
require 'hanami/assets/compressors/stylesheet'
require 'hanami/foo/compressor'

describe Hanami::Assets::Compressors::Stylesheet do
  describe '.for' do
    let(:compressor) { Hanami::Assets::Compressors::Stylesheet.for(engine_name) }

    describe 'when given argument is nil' do
      let(:engine_name) { nil }

      it 'returns NullCompressor' do
        compressor.must_be_kind_of Hanami::Assets::Compressors::NullCompressor
      end
    end

    describe 'when given argument is :yui' do
      let(:engine_name) { :yui }

      it 'returns YuiStylesheet' do
        compressor.must_be_kind_of Hanami::Assets::Compressors::YuiStylesheet
      end
    end

    describe 'when given argument is :sass' do
      let(:engine_name) { :sass }

      it 'returns SassStylesheet' do
        compressor.must_be_kind_of Hanami::Assets::Compressors::SassStylesheet
      end
    end

    describe 'when given argument is unknown symbol' do
      let(:engine_name) { :wat }

      it 'raises error' do
        exception = -> { compressor }.must_raise Hanami::Assets::Compressors::UnknownCompressorError
        exception.message.must_equal "Unknown Stylesheet compressor: :wat"
      end
    end

    describe 'when third party gem' do
      let(:engine_name) { :foo }

      it 'returns FooStylesheet' do
        compressor.must_be_kind_of Hanami::Assets::Compressors::FooStylesheet
      end
    end

    describe 'when anything else' do
      let(:engine_name) { CustomStylesheetCompressor.new }

      it 'is returned as it is' do
        compressor.must_equal engine_name
      end
    end
  end
end
