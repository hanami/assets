# frozen_string_literal: true

require "tmpdir"

RSpec.describe "manifest handling" do
  subject(:assets) { Hanami::Assets.new(config: Hanami::Assets::Config.new(**config_kwargs)) }

  let(:config_kwargs) { {} }

  context "manifest_path configured and real file exists" do
    let(:config_kwargs) { {manifest_path: File.join(@dir, "manifest.json")} }

    before do
      @dir = Dir.mktmpdir
      File.write(File.join(@dir, "manifest.json"), <<~JSON)
        {
          "app.js": {"url": "/path/to/app.js"}
        }
      JSON
    end

    after do
      FileUtils.remove_entry @dir
    end

    it "returns asset paths from the manifest" do
      expect(assets["app.js"].to_s).to eq "/path/to/app.js"
    end

    it "raises an AssetMissingError if an asset can not be found" do
      expect { assets["missing.js"] }
        .to raise_error Hanami::Assets::AssetMissingError, /missing.js/
    end
  end

  context "manifest_path not configured" do
    it "raises a ConfigError" do
      expect { assets["app.js"] }
        .to raise_error Hanami::Assets::ConfigError, "no manifest_path configured"
    end
  end

  context "no file at configured manifest_path" do
    let(:config_kwargs) { {manifest_path: "/missing/manifest.json"} }

    it "raises a ManifestMissingError" do
      expect { assets["app.js"] }
        .to raise_error Hanami::Assets::ManifestMissingError, %r{/missing/manifest.json}
    end
  end
end
