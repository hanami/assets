require 'test_helper'

describe Lotus::Assets::Helpers do

  def safe_string_class
    ::Lotus::Utils::Escape::SafeString
  end

  describe '#javascript' do
    before do
      @javascript = DefaultView.new.javascript('feature-a')
    end

    it 'returns an instance of SafeString' do
      @javascript.must_be_instance_of safe_string_class
    end
  end

  describe '#stylesheet' do
    before do
      @stylesheet = DefaultView.new.stylesheet('main')
    end

    it 'returns an instance of SafeString' do
      @stylesheet.must_be_instance_of safe_string_class
    end
  end

  describe '#image' do
    before do
      @image = DefaultView.new.image('logo', id: 'my-id', class: 'my-class')
    end

    it 'returns an instance of SafeString' do
      @image.must_be_instance_of safe_string_class
    end
  end
end

