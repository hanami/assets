# frozen_string_literal: true

require "uri"
require "dry/inflector"

RSpec.describe Hanami::Assets::Helpers do
  subject(:obj) {
    helpers = described_class
    Class.new {
      include helpers

      attr_reader :_context

      def initialize(context)
        @_context = context
      end
    }.new(context)
  }

  let(:context) {
    double(:context, assets: assets, inflector: inflector)
  }

  def h(&block)
    obj.instance_eval(&block)
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

  describe "#image_tag" do
    def image_tag(...)
      h { image_tag(...) }
    end

    it "returns an instance of HtmlBuilder" do
      actual = image_tag("application.jpg")
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders an <img> tag" do
      actual = image_tag("application.jpg").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    it "custom alt" do
      actual = image_tag("application.jpg", alt: "My Alt").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="My Alt">))
    end

    it "custom data attribute" do
      actual = image_tag("application.jpg", "data-user-id" => 5).to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application" data-user-id="5">))
    end

    it "ignores src passed as an option" do
      actual = image_tag("application.jpg", src: "wrong").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for src attribute" do
        actual = image_tag("application.jpg").to_s
        expect(actual).to eq(%(<img src="#{base_url}/assets/application.jpg" alt="Application">))
      end
    end
  end
end
