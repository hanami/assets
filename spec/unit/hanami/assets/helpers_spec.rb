# frozen_string_literal: true

require "uri"

RSpec.describe Hanami::Assets::Helpers do
  subject do
    described_class.new(configuration: configuration)
  end

  let(:sources) { Sources.path("helpers") }
  let(:destination) { Destination.create }
  let(:base_url) { "https://hanami.test" }
  let(:configuration) { configuration_with_base_url }

  let(:configuration_without_base_url) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  let(:configuration_with_base_url) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new(base_url: base_url) do |config|
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
      let(:configuration) { configuration_without_base_url }

      it "returns the relative path to the asset" do
        expect(subject["application.js"]).to eq("/assets/application.js")
      end
    end

    context "when configured with base url" do
      it "returns the relative path to the asset" do
        expect(subject["application.js"]).to eq("https://hanami.test/assets/application.js")
      end
    end
  end
end
