require 'test_helper'
require 'lotus/assets/compressors/javascript'
require 'lotus/foo/compressor'

describe Lotus::Assets::Compressors::Javascript do
  describe '.for' do
    let(:compressor) { Lotus::Assets::Compressors::Javascript.for(engine_name) }

    describe 'when given argument is nil' do
      let(:engine_name) { nil }

      it 'returns NullCompressor' do
        compressor.must_be_kind_of Lotus::Assets::Compressors::NullCompressor
      end
    end

    describe 'when given argument is :yui' do
      let(:engine_name) { :yui }

      it 'returns YuiJavascript' do
        compressor.must_be_kind_of Lotus::Assets::Compressors::YuiJavascript
      end
    end

    describe 'when given argument is :uglifier' do
      let(:engine_name) { :uglifier }

      it 'returns UglifierJavascript' do
        compressor.must_be_kind_of Lotus::Assets::Compressors::UglifierJavascript
      end
    end

    describe 'when given argument is :closure' do
      let(:engine_name) { :closure }

      it 'returns ClosureJavascript' do
        compressor.must_be_kind_of Lotus::Assets::Compressors::ClosureJavascript
      end
    end

    describe 'when given argument is unknown symbol' do
      let(:engine_name) { :wat }

      it 'raises error' do
        exception = -> { compressor }.must_raise Lotus::Assets::Compressors::UnknownCompressorError
        exception.message.must_equal "Unknown Javascript compressor: :wat"
      end
    end

    describe 'when third party gem' do
      let(:engine_name) { :foo }

      it 'returns FooJavascript' do
        compressor.must_be_kind_of Lotus::Assets::Compressors::FooJavascript
      end
    end

    describe 'when anything else' do
      let(:engine_name) { CustomJavascriptCompressor.new }

      it 'is returned as it is' do
        compressor.must_equal engine_name
      end
    end
  end
end
