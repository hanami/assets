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

  let(:config_kwargs) { {sources: sources_path, destination: destination, base_url: base_url, manifest: manifest}.compact }
  let(:base_url) { nil }
  let(:manifest) { nil }

  let(:config) { Hanami::Assets::Config.new(**config_kwargs) }
  let(:assets) { Hanami::Assets.new(config: config) }
  let(:inflector) { Dry::Inflector.new }

  describe "#favicon_link_tag" do
    def favicon_link_tag(...)
      h { favicon_link_tag(...) }
    end

    it "returns an instance of HtmlBuilder" do
      actual = favicon_link_tag
      expect(actual).to be_instance_of(::Hanami::View::HTML::SafeString)
    end

    it "renders <link> tag" do
      actual = favicon_link_tag.to_s
      expect(actual).to eq(%(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
    end

    it "renders with HTML attributes" do
      actual = favicon_link_tag("favicon.png", rel: "icon", type: "image/png").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="icon" type="image/png">))
    end

    it "ignores href passed as an option" do
      actual = favicon_link_tag("favicon.png", href: "wrong").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="shortcut icon" type="image/x-icon">))
    end

    describe "cdn mode" do
      let(:base_url) { "https://hanami.test" }

      it "returns absolute url for href attribute" do
        actual = favicon_link_tag.to_s
        expect(actual).to eq(%(<link href="#{base_url}/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
      end
    end
  end
end
