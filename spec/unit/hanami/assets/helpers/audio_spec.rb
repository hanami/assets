# frozen_string_literal: true

require "uri"
require "hanami/assets/precompiler"
require "dry/inflector"

RSpec.describe Hanami::Assets::Helpers do
  subject {
    described_class.new(
      assets: assets,
      inflector: inflector
    )
  }

  let(:precompiler) do
    Hanami::Assets::Precompiler.new(configuration: configuration)
  end

  let(:app) { App.create(Test::Sources.path("myapp")) }

  let(:sources_path) { app.join("app", "assets") }
  let(:public_dir) { app.join("public") }
  let(:destination) { public_dir.join("assets") }

  let(:kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest: manifest}.compact }
  let(:base_url) { nil }
  let(:manifest) { nil }

  let(:configuration) { Hanami::Assets::Configuration.new(**kwargs) }
  let(:assets) { Hanami::Assets.new(configuration: configuration) }
  let(:inflector) { Dry::Inflector.new }

  describe "#audio" do
    it "returns an instance of HtmlBuilder" do
      actual = subject.audio_tag("song.ogg")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <audio> tag" do
      actual = subject.audio_tag("song.ogg").to_s
      expect(actual).to eq(%(<audio src="/assets/song.ogg"></audio>))
    end

    it "renders with html attributes" do
      actual = subject.audio_tag("song.ogg", autoplay: true, controls: true).to_s
      expect(actual).to eq(%(<audio autoplay="autoplay" controls="controls" src="/assets/song.ogg"></audio>))
    end

    it "renders with fallback content" do
      actual = subject.audio_tag("song.ogg") do
        "Your browser does not support the audio tag"
      end.to_s

      expect(actual).to eq(%(<audio src="/assets/song.ogg">Your browser does not support the audio tag</audio>))
    end

    it "renders with tracks" do
      actual = subject.audio_tag("song.ogg") do
        tag.track kind: "captions", src: subject.path("song.pt-BR.vtt"), srclang: "pt-BR", label: "Portuguese"
      end.to_s

      expect(actual).to eq(%(<audio src="/assets/song.ogg"><track kind="captions" src="/assets/song.pt-BR.vtt" srclang="pt-BR" label="Portuguese"></audio>))
    end

    xit "renders with sources" do
      actual = subject.audio_tag do
        tag.text "Your browser does not support the audio tag"
        tag.source src: subject.path("song.ogg"), type: "audio/ogg"
        tag.source src: subject.path("song.wav"), type: "audio/wav"
      end.to_s

      expect(actual).to eq(%(<audio>Your browser does not support the audio tag<source src="/assets/song.ogg" type="audio/ogg"><source src="/assets/song.wav" type="audio/wav"></audio>))
    end

    it "raises an exception when no arguments" do
      expect do
        subject.audio_tag
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    it "raises an exception when no src and no block" do
      expect do
        subject.audio_tag(controls: true)
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for src attribute" do
        actual = subject.audio_tag("song.ogg").to_s
        expect(actual).to eq(%(<audio src="#{base_url}/assets/song.ogg"></audio>))
      end
    end

    private

    def tag(...)
      subject.__send__(:tag, ...)
    end
  end
end
