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
  # let(:app) { App.create(Sources.path("helpers")) }

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

  describe "#initialize" do
    it "returns an instance of #{described_class}" do
      expect(subject).to be_an_instance_of(described_class)
    end
  end

  describe "#[]" do
    context "when configurated relative path only" do
      context "without manifest" do
        it "returns the relative path to the asset" do
          expect(subject["application.js"]).to eq("/assets/application.js")
        end
      end

      context "with manifest" do
        before do
          Dir.chdir(app) { precompiler.call }
          configuration.finalize!
        end

        let(:manifest) { public_dir.join("assets.json") }

        it "returns the relative path to the asset" do
          expect(subject["index.js"]).to eq("/assets/index-WIMS7JIO.js")
        end
      end
    end

    context "when configured with base url" do
      let(:base_url) { "https://hanami.test" }

      context "without manifest" do
        it "returns the relative path to the asset" do
          expect(subject["application.js"]).to eq("https://hanami.test/assets/application.js")
        end
      end

      context "with manifest" do
        before do
          Dir.chdir(app) { precompiler.call }
          configuration.finalize!
        end

        let(:manifest) { public_dir.join("assets.json") }

        it "returns the relative path to the asset" do
          expect(subject["index.js"]).to eq("https://hanami.test/assets/index-WIMS7JIO.js")
        end
      end
    end
  end
end
