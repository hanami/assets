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

  describe "#favicon" do
    it "returns an instance of HtmlBuilder" do
      actual = subject.favicon
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <link> tag" do
      actual = subject.favicon.to_s
      expect(actual).to eq(%(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
    end

    it "renders with HTML attributes" do
      actual = subject.favicon("favicon.png", rel: "icon", type: "image/png").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="icon" type="image/png">))
    end

    it "ignores href passed as an option" do
      actual = subject.favicon("favicon.png", href: "wrong").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="shortcut icon" type="image/x-icon">))
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for href attribute" do
        actual = subject.favicon.to_s
        expect(actual).to eq(%(<link href="#{base_url}/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        subject.favicon
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows assets inclusion in push promise assets" do
        actual = subject.favicon("favicon.ico", push: true).to_s
        expect(actual).to eq(%(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/favicon.ico")).to eq(as: :image, crossorigin: false)
      end

      it "allows crossorigin assets inclusion in push promise assets" do
        actual = subject.favicon("https://assets.hanamirb.org/assets/favicon.ico", push: true).to_s
        expect(actual).to eq(%(<link href="https://assets.hanamirb.org/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/favicon.ico")).to eq(as: :image, crossorigin: true)
      end
    end
  end
end
