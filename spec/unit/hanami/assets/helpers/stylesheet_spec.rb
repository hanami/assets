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

  let(:configuration_kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest_path: manifest_path}.compact }
  let(:base_url) { nil }
  let(:manifest_path) { nil }

  let(:configuration) { Hanami::Assets::Configuration.new(**configuration_kwargs) }
  let(:assets) { Hanami::Assets.new(configuration: configuration) }
  let(:inflector) { Dry::Inflector.new }

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

      let(:manifest_path) { public_dir.join("assets.json") }

      it "includes subresource_integrity and crossorigin attributes" do
        actual = subject.stylesheet("app")
        expect(actual).to eq(%(<link href="/assets/app-N47SR66M.css" type="text/css" rel="stylesheet" integrity="sha384-e6Xvf6L9/vqEmC9y0ZTQ6yVW+a8PrkPNWU+qeNoJZdRrc15yY9AuWqywRWx5EjLk" crossorigin="anonymous">))
      end
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for href attribute" do
        actual = subject.stylesheet("app")
        expect(actual).to eq(%(<link href="#{base_url}/assets/app.css" type="text/css" rel="stylesheet">))
      end
    end
  end
end
