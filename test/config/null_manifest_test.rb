require 'test_helper'
require 'pp'

describe Hanami::Assets::Config::NullManifest do
  let(:configuration) { Hanami::Assets::Configuration.new }
  let(:manifest)      { Hanami::Assets::Config::NullManifest.new(configuration) }

  it 'is pretty printable' do
    pp manifest
  end
end
