# frozen_string_literal: true

require "uri"
require "hanami/assets/precompiler"

RSpec.describe Hanami::Assets::Helpers do
  subject { described_class.new(configuration: configuration) }

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

  before do
    Thread.current[:__hanami_assets] = nil
  end

  describe "#asset_path" do
    it "returns relative URL for given asset name" do
      result = subject.asset_path("application.js")
      expect(result).to eq("/assets/application.js")
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = subject.asset_path("http://assets.hanamirb.org/assets/application.css")
      expect(result).to eq("http://assets.hanamirb.org/assets/application.css")
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url" do
        result = subject.asset_path("application.js")
        expect(result).to eq("#{base_url}/assets/application.js")
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't add into assets list by default" do
        subject.asset_path("dashboard.js")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "adds asset into assets list" do
        subject.asset_path("dashboard.js", push: true)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("/assets/dashboard.js")).to eq(as: nil, crossorigin: false)
      end

      it "allows to specify asset type" do
        subject.asset_path("video.mp4", push: :video)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("/assets/video.mp4")).to eq(as: :video, crossorigin: false)
      end

      it "allows to link crossorigin asset" do
        subject.asset_path("https://assets.hanamirb.org/assets/video.mp4", push: :video)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("https://assets.hanamirb.org/assets/video.mp4")).to eq(as: :video, crossorigin: true)
      end
    end
  end
end
