# frozen_string_literal: true

RSpec.describe "Hanami::Assets::VERSION" do
  it "exposes version" do
    expect(Hanami::Assets::VERSION).to eq("1.3.5")
  end
end
