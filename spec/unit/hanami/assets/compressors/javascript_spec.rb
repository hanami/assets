# frozen_string_literal: true

require "hanami/assets/compressors/javascript"
require "hanami/foo/compressor"

describe Hanami::Assets::Compressors::Javascript do
  describe ".for" do
    let(:compressor) { Hanami::Assets::Compressors::Javascript.for(engine_name) }

    describe "when given argument is nil" do
      let(:engine_name) { nil }

      it "returns NullCompressor" do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::NullCompressor)
      end
    end

    describe "when given argument is :yui" do
      let(:engine_name) { :yui }

      it "returns YuiJavascript" do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::YuiJavascript)
      end
    end

    describe "when given argument is :uglifier" do
      let(:engine_name) { :uglifier }

      it "returns UglifierJavascript" do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::UglifierJavascript)
      end
    end

    describe "when given argument is :closure" do
      let(:engine_name) { :closure }

      it "returns ClosureJavascript" do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::ClosureJavascript)
      end
    end

    describe "when given argument is unknown symbol" do
      let(:engine_name) { :wat }

      it "raises error" do
        expect { compressor }.to raise_error(Hanami::Assets::Compressors::UnknownCompressorError,
                                             "Unknown Javascript compressor: :wat")
      end
    end

    describe "when third party gem" do
      let(:engine_name) { :foo }

      it "returns FooJavascript" do
        expect(compressor).to be_kind_of(Hanami::Assets::Compressors::FooJavascript)
      end
    end

    describe "when anything else" do
      let(:engine_name) { CustomJavascriptCompressor.new }

      it "is returned as it is" do
        expect(compressor).to eq(engine_name)
      end
    end
  end
end
