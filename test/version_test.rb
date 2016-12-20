require 'test_helper'

describe Hanami::Assets::VERSION do
  it 'exposes version' do
    Hanami::Assets::VERSION.must_equal '1.0.0.beta1'
  end
end
