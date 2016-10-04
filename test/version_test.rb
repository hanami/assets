require 'test_helper'

describe Hanami::Assets::VERSION do
  it 'exposes version' do
    Hanami::Assets::VERSION.must_equal '0.4.0'
  end
end
