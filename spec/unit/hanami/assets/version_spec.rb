RSpec.describe "Hanami::Assets::VERSION" do
  it "exposes version" do
    expect(Hanami::Assets::VERSION).to eq("1.2.0")
  end
end
