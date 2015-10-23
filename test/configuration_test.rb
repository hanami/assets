require 'test_helper'

describe Lotus::Assets::Configuration do
  before do
    @configuration = Lotus::Assets::Configuration.new
  end

  after do
    @configuration.reset!
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
        tag %(<link rel="text/x-custom src="%s">)
        ext %(.custom)
      end

      asset = @configuration.asset(:custom)
      asset.tag.must_equal %(<link rel="text/x-custom src="%s">)
      asset.ext.must_equal %(.custom)
    end

    it 'accepts strings as name of the asset type' do
      @configuration.define 'custom2' do
        ext %(.custom2)
      end

      asset = @configuration.asset(:custom2)
      asset.ext.must_equal %(.custom2)
    end

    it 'allows to modify existing asset types' do
      @configuration.define :javascript do
        prefix 'dest-js'
      end

      asset = @configuration.asset(:javascript)
      asset.tag.must_equal    %(<script src="%s" type="text/javascript"></script>)
      asset.ext.must_equal    %(.js)
      asset.prefix.must_equal %(dest-js)
    end
  end

  describe '#destination' do
    it 'defaults to "public/" on current directory' do
      expected = Pathname.new(Dir.pwd + '/public')
      @configuration.destination.must_equal(expected)
    end

    it 'allows to set a custom location' do
      dest = __dir__ + '/../tmp'
      @configuration.destination(dest)
      @configuration.destination.must_equal(Pathname.new(dest))
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

  describe '#reset!' do
    before do
      @configuration.prefix 'prfx'
      @configuration.destination(Dir.pwd + '/tmp')

      @configuration.define :stylesheet do
        ext %(.CSS)
      end

      @configuration.define :cuztom do
        tag %(<link rel="text/xy-custom src="%s">)
        ext %(.cstm)
      end

      @configuration.reset!
    end

    it 'sets default value for destination' do
      @configuration.destination.must_equal(Pathname.new(Dir.pwd + '/public'))
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
      asset.tag.must_equal    %(<link href="%s" type="text/css" rel="stylesheet">)
      asset.ext.must_equal    %(.css)
      asset.prefix.must_equal %(/assets)
    end
  end

  describe '#duplicate' do
    before do
      @configuration.reset!
      @configuration.compile     true
      @configuration.prefix      '/foo'
      @configuration.root        __dir__
      @configuration.destination __dir__
      @configuration.define(:movie) do
        tag %(<movie>)
        ext %(.mov)
      end

      @config = @configuration.duplicate
    end

    it 'returns a copy of the configuration' do
      @config.compile.must_equal      true
      @config.prefix.must_equal      '/foo'
      @config.root.must_equal        Pathname.new(__dir__)
      @config.destination.must_equal Pathname.new(__dir__)
      @config.__send__(:types).types.must_equal [:javascript, :stylesheet, :movie]
    end

    it "doesn't affect the original configuration" do
      @config.compile     false
      @config.prefix      '/bar'
      @config.root        __dir__ + '/fixtures'
      @config.destination __dir__ + '/fixtures'
      @config.define(:javascript) do
        sources << [
          __dir__ + '/fixtures/javascripts'
        ]
      end

      @config.define(:font) do
        tag %(<font>)
        ext %(.woff)
      end

      @config.compile.must_equal      false
      @config.prefix.must_equal      '/bar'
      @config.root.must_equal        Pathname.new(__dir__ + '/fixtures')
      @config.destination.must_equal Pathname.new(__dir__ + '/fixtures')
      @config.__send__(:types).types.must_equal [:javascript, :stylesheet, :movie, :font]
      assert @config.asset(:javascript).sources == [__dir__ + '/fixtures/javascripts'],
        "Expected javascripts to eq [#{ __dir__ + '/fixtures/javascripts' }], found: #{ @configuration.asset(:javascript).sources.inspect }"

      @configuration.compile.must_equal      true
      @configuration.prefix.must_equal      '/foo'
      @configuration.root.must_equal        Pathname.new(__dir__)
      @configuration.destination.must_equal Pathname.new(__dir__)
      @configuration.__send__(:types).types.must_equal [:javascript, :stylesheet, :movie]

      assert @configuration.asset(:javascript).sources == [],
        "Expected javascripts to be empty, found: #{ @configuration.asset(:javascript).sources.inspect }"
    end
  end
end
