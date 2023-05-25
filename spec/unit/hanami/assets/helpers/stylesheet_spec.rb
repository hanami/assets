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

  describe "#stylesheet" do
    it "returns an instance of SafeString" do
      actual = subject.stylesheet("main")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <link> tag" do
      actual = subject.stylesheet("main")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet">))
    end

    it "renders <link> tag without appending ext after query string" do
      actual = subject.stylesheet("fonts?font=Helvetica")
      expect(actual).to eq(%(<link href="/assets/fonts?font=Helvetica" type="text/css" rel="stylesheet">))
    end

    it "renders <link> tag with an integrity attribute" do
      actual = subject.stylesheet("main", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous">))
    end

    it "renders <link> tag with a crossorigin attribute" do
      actual = subject.stylesheet("main", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC", crossorigin: "use-credentials")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials">))
    end

    it "ignores href passed as an option" do
      actual = subject.stylesheet("main", href: "wrong")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet">))
    end

    describe "subresource_integrity mode" do
      before do
        configuration.subresource_integrity = [:sha384]
        Dir.chdir(app) { precompiler.call }
        configuration.finalize!
      end

      let(:manifest) { public_dir.join("assets.json") }

      it "includes subresource_integrity and crossorigin attributes" do
        actual = subject.stylesheet("app")
        expect(actual).to eq(%(<link href="/assets/app-BDJPH3XR.css" type="text/css" rel="stylesheet" integrity="sha384-AT14m59DGIJJp8AsoZmdt25b0+KdyQYMC7ARf9DgmNtmtGddGr/2TaGUgBCR5x+v" crossorigin="anonymous">))
      end
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for href attribute" do
        actual = subject.stylesheet("app")
        expect(actual).to eq(%(<link href="#{base_url}/assets/app.css" type="text/css" rel="stylesheet">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "includes asset in push promise assets" do
        subject.stylesheet("main")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/main.css")).to eq(as: :style, crossorigin: false)
      end

      it "allows asset exclusion from push promise assets" do
        actual = subject.stylesheet("fonts", push: false)
        expect(actual).to eq(%(<link href="/assets/fonts.css" type="text/css" rel="stylesheet">))
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "includes multiple assets in push promise assets" do
        subject.stylesheet("framework", "styles")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/framework.css")).to eq(as: :style, crossorigin: false)
        expect(assets.fetch("/assets/styles.css")).to eq(as: :style, crossorigin: false)
      end

      it "allows the exclusion of multiple assets from push promise assets" do
        subject.stylesheet("framework", "styles", push: false)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end
    end
  end
end
