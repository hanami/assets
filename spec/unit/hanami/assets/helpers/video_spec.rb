# frozen_string_literal: true

require "uri"
require "hanami/assets/precompiler"
require "dry/inflector"

RSpec.describe Hanami::Assets::Helpers do
  subject { described_class.new(configuration: configuration, inflector: inflector) }

  let(:precompiler) do
    Hanami::Assets::Precompiler.new(configuration: configuration)
  end

  let(:app) { App.create(source) }
  let(:source) { Sources.path("myapp") }

  let(:sources) { app.join("app", "assets") }
  let(:public_dir) { app.join("public") }
  let(:destination) { public_dir.join("assets") }

  let(:kwargs) { {base_url: base_url, manifest: manifest}.compact }
  let(:base_url) { nil }
  let(:manifest) { nil }

  let(:configuration) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new(**kwargs) do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  let(:inflector) { Dry::Inflector.new }

  before do
    Thread.current[:__hanami_assets] = nil
  end

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

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        subject.video("movie.mp4")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows asset inclusion in push promise assets" do
        actual = subject.video("movie.mp4", push: true).to_s
        expect(actual).to eq(%(<video src="/assets/movie.mp4"></video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end

      it "allows crossorigin asset inclusion in push promise assets" do
        actual = subject.video("https://assets.hanamirb.org/assets/movie.mp4", push: true).to_s
        expect(actual).to eq(%(<video src="https://assets.hanamirb.org/assets/movie.mp4"></video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/movie.mp4")).to eq(as: :video, crossorigin: true)
      end

      it "allows asset inclusion in push promise assets when using block syntax" do
        actual = subject.video("movie.mp4", push: true) do
          "Your browser does not support the video tag"
        end.to_s

        expect(actual).to eq(%(<video src="/assets/movie.mp4">Your browser does not support the video tag</video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end

      xit "allows asset inclusion in push promise assets when using block syntax and source tags" do
        actual = subject.video do
          tag.text "Your browser does not support the video tag"
          tag.source src: subject.path("movie.mp4", push: :video), type: "video/mp4"
          tag.source src: subject.path("movie.ogg"), type: "video/ogg"
        end.to_s

        expect(actual).to eq(%(<video>Your browser does not support the video tag<source src="/assets/movie.mp4" type="video/mp4"><source src="/assets/movie.ogg" type="video/ogg"></video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end
    end

    private

    def tag(...)
      subject.__send__(:tag, ...)
    end
  end
end
