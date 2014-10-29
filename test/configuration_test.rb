require 'test_helper'

describe Lotus::Assets::Configuration do
  before do
    @configuration = Lotus::Assets::Configuration.new
  end

  describe '#prefix' do
    it 'returns empty value default' do
      @configuration.prefix.must_be_kind_of(Lotus::Utils::PathPrefix)
      @configuration.prefix.to_s.must_be_empty
    end

    it 'allows to set a value' do
      @configuration.prefix            'application-prefix'
      @configuration.prefix.must_equal 'application-prefix'
    end
  end

  describe '#define' do
    it 'allows to define a custom asset type' do
      @configuration.define :custom do
        tag      %(<link rel="text/x-custom src="%s">)
        filename %(%s.custom)
      end

      asset = @configuration.asset(:custom)
      asset.tag.must_equal      %(<link rel="text/x-custom src="%s">)
      asset.filename.must_equal %(%s.custom)
    end

    it 'accepts strings as name of the asset type' do
      @configuration.define 'custom2' do
        filename %(%s.custom2)
      end

      asset = @configuration.asset(:custom2)
      asset.filename.must_equal %(%s.custom2)
    end

    it 'allows to modify existing asset types' do
      @configuration.define :javascript do
        prefix 'dest-js'
      end

      asset = @configuration.asset(:javascript)
      asset.tag.must_equal      %(<script src="%s" type="text/javascript"></script>)
      asset.filename.must_equal %(%s.js)
      asset.prefix.must_equal   %(dest-js)
    end
  end

  describe '#reset!' do
    before do
      @configuration.prefix 'prfx'

      @configuration.define :stylesheet do
        filename %(%s.CSS)
      end

      @configuration.define :cuztom do
        tag      %(<link rel="text/xy-custom src="%s">)
        filename %(%s.cstm)
      end

      @configuration.reset!
    end

    it 'sets default value for prefix' do
      @configuration.prefix.must_be_kind_of(Lotus::Utils::PathPrefix)
      @configuration.prefix.to_s.must_be_empty
    end

    it 'removes custom defined asset types' do
      -> { @configuration.asset(:cuztom) }.must_raise Lotus::Assets::UnknownAssetType
    end

    it 'sets default value for predefined asset type' do
      asset = @configuration.asset(:stylesheet)
      asset.tag.must_equal      %(<link href="%s" type="text/css" rel="stylesheet">)
      asset.filename.must_equal %(%s.css)
      asset.prefix.must_equal   %(/assets)
    end
  end

  describe '#asset' do
    it 'returns an asset definition' do
      @configuration.asset(:javascript).must_be_kind_of(Lotus::Assets::Config::AssetType)
    end

    it 'raises error for unkown type' do
      exception = -> { @configuration.asset(:unkown) }.must_raise(Lotus::Assets::UnknownAssetType)
      exception.message.must_equal %(Unknown asset type: `unkown')
    end
  end
end
