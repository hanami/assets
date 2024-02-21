# frozen_string_literal: true

RSpec.describe Hanami::Assets, ".public_assets_dir" do
  subject(:public_assets_dir) { described_class.public_assets_dir(slice) }

  let(:slice) { double(:slice, slice_name: double(to_s: slice_name), app: double(:app)) }
  let(:slice_name) { "main" }

  describe "top-level slices" do
    it "underscores the slice name" do
      expect(public_assets_dir).to eq "_main"
    end
  end

  describe "nested slices" do
    let(:slice_name) { "main/nested" }

    it "underscores all name segments" do
      expect(public_assets_dir).to eq "_main/_nested"
    end
  end

  describe "app" do
    before do
      allow(slice).to receive(:app) { slice }
    end

    it "returns nil" do
      expect(public_assets_dir).to be nil
    end
  end
end
