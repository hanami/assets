require 'test_helper'

describe Lotus::Assets::Configuration do
  before do
    @configuration = Lotus::Assets::Configuration.new
  end

  describe 'defaults' do
    it 'has a predefined type for javascript' do
      asset = @configuration.__send__(:asset, :javascript)
      asset.tag.must_equal    %(<script src="%s" type="text/javascript"></script>)
      asset.source.must_equal %(/%s.js)
      asset.path.must_equal   %(assets)
    end

    it 'has a predefined type for stylesheet' do
      asset = @configuration.__send__(:asset, :stylesheet)
      asset.tag.must_equal    %(<link href="%s" type="text/css" rel="stylesheet">)
      asset.source.must_equal %(/%s.css)
      asset.path.must_equal   %(assets)
    end
  end

  describe '#prefix' do
    it 'returns nil by default' do
      @configuration.prefix.must_be_nil
    end

    it 'allows to set a value' do
      @configuration.prefix            'application-prefix'
      @configuration.prefix.must_equal 'application-prefix'
    end
  end

  describe '#define' do
    it 'allows to define a custom asset type' do
      @configuration.define :custom do
        tag    %(<link rel="text/x-custom src="%s">)
        source %(/%s.custom)
      end

      asset = @configuration.__send__(:asset, :custom)
      asset.tag.must_equal    %(<link rel="text/x-custom src="%s">)
      asset.source.must_equal %(/%s.custom)
    end

    it 'allows to modify existing asset types' do
      @configuration.define :javascript do
        path 'dest-js'
      end

      asset = @configuration.__send__(:asset, :javascript)
      asset.tag.must_equal    %(<script src="%s" type="text/javascript"></script>)
      asset.source.must_equal %(/%s.js)
      asset.path.must_equal   %(dest-js)
    end
  end

  describe '#reset!' do
    before do
      @configuration.prefix 'prfx'

      @configuration.define :stylesheet do
        source %(/%s.CSS)
      end

      @configuration.define :cuztom do
        tag    %(<link rel="text/xy-custom src="%s">)
        source %(/%s.cstm)
      end

      @configuration.reset!
    end

    it 'sets default value for prefix' do
      @configuration.prefix.must_be_nil
    end

    it 'removes custom defined asset types' do
      -> { @configuration.__send__(:asset, :cuztom) }.must_raise Lotus::Assets::UnknownAssetType
    end

    it 'sets default value for predefined asset type' do
      asset = @configuration.__send__(:asset, :stylesheet)
      asset.tag.must_equal    %(<link href="%s" type="text/css" rel="stylesheet">)
      asset.source.must_equal %(/%s.css)
      asset.path.must_equal   %(assets)
    end
  end

  describe '#asset_tag' do
    it 'returns a relative url' do
      result = @configuration.asset_tag(:javascript, 'signin')
      result.must_equal %(<script src="/assets/signin.js" type="text/javascript"></script>)
    end

    it 'returns an absoulte url' do
      result = @configuration.asset_tag(:javascript, 'https://code.jquery.com/jquery-2.1.1.min.js')
      result.must_equal %(<script src="https://code.jquery.com/jquery-2.1.1.min.js" type="text/javascript"></script>)
    end

    it 'raises an error for unkown type' do
      exception = -> { @configuration.asset_tag(:unkown, 'feature-c') }.must_raise(Lotus::Assets::UnknownAssetType)
      exception.message.must_equal %(Unknown asset type: `unkown')
    end

    describe 'with custom defined type' do
      before do
        @configuration.define :custom do
          tag    %(<link rel="text/x-custom src="%s">)
          source %(/%s.custom)
        end
      end

      it 'returns the asset tag' do
        result = @configuration.asset_tag(:custom, 'feature-d')
        result.must_equal %(<link rel="text/x-custom src="/assets/feature-d.custom">)
      end
    end
  end
end
