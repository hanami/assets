require 'test_helper'

describe Lotus::Assets::Helpers do

  def safe_string_class
    ::Lotus::Utils::Escape::SafeString
  end

  describe '#javascript' do
    before do
      @javascript = View.new.javascript('feature-a')
    end

    it 'returns an instance of SafeString' do
      @javascript.must_be_instance_of safe_string_class
    end
  end

  describe '#stylesheet' do
    before do
      @stylesheet = View.new.stylesheet('main')
    end

    it 'returns an instance of SafeString' do
      @stylesheet.must_be_instance_of safe_string_class
    end
  end
end

