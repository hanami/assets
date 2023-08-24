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

  describe "#javascript" do
    it "returns an instance of SafeString" do
      actual = subject.javascript_tag("feature-a")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <script> tag" do
      actual = subject.javascript_tag("feature-a")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
    end

    it "renders <script> tag without appending ext after query string" do
      actual = subject.javascript_tag("feature-x?callback=init")
      expect(actual).to eq(%(<script src="/assets/feature-x?callback=init" type="text/javascript"></script>))
    end

    it "renders <script> tag with a defer attribute" do
      actual = subject.javascript_tag("feature-a", defer: true)
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" defer="defer"></script>))
    end

    it "renders <script> tag with an integrity attribute" do
      actual = subject.javascript_tag("feature-a", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>))
    end

    it "renders <script> tag with a crossorigin attribute" do
      actual = subject.javascript_tag("feature-a", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC", crossorigin: "use-credentials")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials"></script>))
    end

    it "ignores src passed as an option" do
      actual = subject.javascript_tag("feature-a", src: "wrong")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
    end

    describe "async option" do
      it "renders <script> tag with an async=true if async option is true" do
        actual = subject.javascript_tag("feature-a", async: true)
        expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" async="async"></script>))
      end

      it "renders <script> tag without an async=true if async option is false" do
        actual = subject.javascript_tag("feature-a", async: false)
        expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
      end
    end

    describe "subresource_integrity mode" do
      before do
        configuration.subresource_integrity = [:sha384]
        Dir.chdir(app) { precompiler.call }
        configuration.finalize!
      end

      let(:manifest_path) { public_dir.join("assets.json") }

      it "includes subresource_integrity and crossorigin attributes" do
        actual = subject.javascript_tag("app")
        expect(actual).to eq(%(<script src="/assets/app-A5GJ52WC.js" type="text/javascript" integrity="sha384-cf36d5R7yH+P7TOpN7kJN9DMKPlsVbYntmPdAwgvL/01Z2nFTN86JaIrfwA3us5N" crossorigin="anonymous"></script>))
      end
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for src attribute" do
        actual = subject.javascript_tag("feature-a")
        expect(actual).to eq(%(<script src="#{base_url}/assets/feature-a.js" type="text/javascript"></script>))
      end
    end
  end
end
