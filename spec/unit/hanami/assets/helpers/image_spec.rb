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

  describe "#image" do
    it "returns an instance of HtmlBuilder" do
      actual = subject.image("application.jpg")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders an <img> tag" do
      actual = subject.image("application.jpg").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    it "custom alt" do
      actual = subject.image("application.jpg", alt: "My Alt").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="My Alt">))
    end

    it "custom data attribute" do
      actual = subject.image("application.jpg", "data-user-id" => 5).to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application" data-user-id="5">))
    end

    it "ignores src passed as an option" do
      actual = subject.image("application.jpg", src: "wrong").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for src attribute" do
        actual = subject.image("application.jpg").to_s
        expect(actual).to eq(%(<img src="#{base_url}/assets/application.jpg" alt="Application">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        subject.image("application.jpg")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows assets inclusion in push promise assets" do
        actual = subject.image("application.jpg", push: true).to_s
        expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/application.jpg")).to eq(as: :image, crossorigin: false)
      end

      it "allows crossorigin assets inclusion in push promise assets" do
        actual = subject.image("https://assets.hanamirb.org/assets/application.jpg", push: true).to_s
        expect(actual).to eq(%(<img src="https://assets.hanamirb.org/assets/application.jpg" alt="Application">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/application.jpg")).to eq(as: :image, crossorigin: true)
      end
    end
  end
end
