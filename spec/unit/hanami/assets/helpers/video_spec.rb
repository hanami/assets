# frozen_string_literal: true

require "uri"
require "hanami/assets/precompiler"
require "dry/inflector"

RSpec.describe Hanami::Assets::Helpers do
  subject {
    described_class.new(
      configuration: configuration,
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

  let(:configuration_kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest: manifest}.compact }
  let(:base_url) { nil }
  let(:manifest) { nil }

  let(:configuration) { Hanami::Assets::Configuration.new(**configuration_kwargs) }
  let(:assets) { Hanami::Assets.new(configuration: configuration) }
  let(:inflector) { Dry::Inflector.new }

  describe "#video" do
    it "returns an instance of HtmlBuilder" do
      actual = subject.video("movie.mp4")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <video> tag" do
      actual = subject.video("movie.mp4").to_s
      expect(actual).to eq(%(<video src="/assets/movie.mp4"></video>))
    end

    it "renders with html attributes" do
      actual = subject.video("movie.mp4", autoplay: true, controls: true).to_s
      expect(actual).to eq(%(<video autoplay="autoplay" controls="controls" src="/assets/movie.mp4"></video>))
    end

    it "renders with fallback content" do
      actual = subject.video("movie.mp4") do
        "Your browser does not support the video tag"
      end.to_s

      expect(actual).to eq(%(<video src="/assets/movie.mp4">Your browser does not support the video tag</video>))
    end

    it "renders with tracks" do
      actual = subject.video("movie.mp4") do
        tag.track kind: "captions", src: subject.path("movie.en.vtt"), srclang: "en", label: "English"
      end.to_s

      expect(actual).to eq(%(<video src="/assets/movie.mp4"><track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English"></video>))
    end

    xit "renders with sources" do
      actual = subject.video do
        tag.text "Your browser does not support the video tag"
        tag.source src: subject.path("movie.mp4"), type: "video/mp4"
        tag.source src: subject.path("movie.ogg"), type: "video/ogg"
      end.to_s

      expect(actual).to eq(%(<video>Your browser does not support the video tag<source src="/assets/movie.mp4" type="video/mp4"><source src="/assets/movie.ogg" type="video/ogg"></video>))
    end

    it "raises an exception when no arguments" do
      expect do
        subject.video
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    it "raises an exception when no src and no block" do
      expect do
        subject.video(content: true)
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for src attribute" do
        actual = subject.video("movie.mp4").to_s
        expect(actual).to eq(%(<video src="#{base_url}/assets/movie.mp4"></video>))
      end
    end

    private

    def tag(...)
      subject.__send__(:tag, ...)
    end
  end
end
