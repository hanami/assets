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

  let(:configuration_kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest: manifest}.compact }
  let(:base_url) { nil }
  let(:manifest) { nil }

  let(:configuration) { Hanami::Assets::Configuration.new(**configuration_kwargs) }
  let(:assets) { Hanami::Assets.new(configuration: configuration) }
  let(:inflector) { Dry::Inflector.new }

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
  end
end
