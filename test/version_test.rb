require 'test_helper'

describe Lotus::Assets::VERSION do
  it 'exposes version' do
    Lotus::Assets::VERSION.must_equal '0.1.0'
  end
end
