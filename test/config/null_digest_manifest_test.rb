require 'test_helper'
require 'pp'

describe Hanami::Assets::Config::NullDigestManifest do
  let(:configuration) { Hanami::Assets::Configuration.new }
  let(:manifest)      { Hanami::Assets::Config::NullDigestManifest.new(configuration) }

  it 'is pretty printable' do
    pp manifest
  end
end
