# frozen_string_literal: true

describe "Hanami::Assets::VERSION" do
  it "exposes version" do
    expect(Hanami::Assets::VERSION).to eq("1.1.0")
  end
end
