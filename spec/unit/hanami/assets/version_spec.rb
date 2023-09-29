# frozen_string_literal: true

RSpec.describe "Hanami::Assets::VERSION" do
  it "exposes version" do
    expect(Hanami::Assets::VERSION).to eq("2.1.0.beta2")
  end
end
