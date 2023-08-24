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

  let(:configuration_kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest_path: manifest_path}.compact }
  let(:base_url) { nil }
  let(:manifest_path) { nil }

  let(:configuration) { Hanami::Assets::Configuration.new(**configuration_kwargs) }
  let(:assets) { Hanami::Assets.new(configuration: configuration) }
  let(:inflector) { Dry::Inflector.new }

  describe "#[]" do
    context "when configurated relative path only" do
      context "without manifest" do
        it "returns the relative URL to the asset" do
          expect(subject.path("application.js")).to eq("/assets/application.js")
        end

        it "returns absolute URL if the argument is an absolute URL" do
          result = subject.path("http://assets.hanamirb.org/assets/application.css")
          expect(result).to eq("http://assets.hanamirb.org/assets/application.css")
        end
      end

      context "with manifest" do
        before do
          FileUtils.ln_sf(File.join(Dir.pwd, "node_modules"), app.join("node_modules"))
          Dir.chdir(app) { precompiler.call }
          configuration.finalize!
        end

        let(:manifest_path) { public_dir.join("assets.json") }

        it "returns the relative URL to the asset" do
          expect(subject.path("app.js")).to eq("/assets/app-A5GJ52WC.js")
        end
      end
    end

    context "when configured with base url" do
      let(:base_url) { "https://hanami.test" }

      context "without manifest" do
        it "returns the absolute URL to the asset" do
          expect(subject.path("application.js")).to eq("#{base_url}/assets/application.js")
        end
      end

      context "with manifest" do
        before do
          FileUtils.ln_sf(File.join(Dir.pwd, "node_modules"), app.join("node_modules"))
          Dir.chdir(app) { precompiler.call }
          configuration.finalize!
        end

        let(:manifest_path) { public_dir.join("assets.json") }

        it "returns the relative path to the asset" do
          expect(subject.path("app.js")).to eq("https://hanami.test/assets/app-A5GJ52WC.js")
        end
      end
    end
  end
end
