require 'test_helper'

describe 'Default asset types' do
  before do
    @configuration = Lotus::Assets::Configuration.new
  end

  describe 'javascript' do
    it 'has a predefined type' do
      asset = @configuration.asset(:javascript)
      asset.tag.must_equal    %(<script src="%s" type="text/javascript"></script>)
      asset.ext.must_equal    %(.js)
      asset.prefix.must_equal %(/assets)
    end
  end

  describe 'stylesheet' do
    it 'has a predefined type' do
      asset = @configuration.asset(:stylesheet)
      asset.tag.must_equal    %(<link href="%s" type="text/css" rel="stylesheet">)
      asset.ext.must_equal    %(.css)
      asset.prefix.must_equal %(/assets)
    end
  end
end
