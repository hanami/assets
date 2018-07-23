require 'pp'

RSpec.describe Hanami::Assets::Config::NullManifest do
  let(:configuration) { Hanami::Assets::Configuration.new }
  let(:manifest)      { Hanami::Assets::Config::NullManifest.new(configuration) }

  it 'is pretty printable' do
    expect { pp manifest }.to output(%r{Hanami::Assets::Config::NullManifest}).to_stdout
  end
end
