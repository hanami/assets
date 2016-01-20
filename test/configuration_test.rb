require 'test_helper'
require 'hanami/assets/compressors/javascript'
require 'hanami/assets/compressors/stylesheet'

describe Hanami::Assets::Configuration do
  before do
    @configuration = Hanami::Assets::Configuration.new
  end

  after do
    @configuration.reset!
  end

  describe '#javascript_compressor' do
    describe "default" do
      it "is nil by default" do
        @configuration.javascript_compressor.must_be_nil
      end

      it "returns NullCompressor for internal usage" do
        @configuration.js_compressor.must_be_kind_of Hanami::Assets::Compressors::NullCompressor
      end
    end

    describe "when :yui" do
      before do
        @configuration.javascript_compressor :yui
      end

      it "returns value before to load configuration" do
        @configuration.javascript_compressor.must_equal :yui
      end

      it "is instance of Hanami::Assets::Compressors::YuiJavascriptCompressor" do
        @configuration.js_compressor.must_be_kind_of Hanami::Assets::Compressors::YuiJavascript
      end
    end

    describe "when object" do
      before do
        @configuration.javascript_compressor compressor
      end

      let(:compressor) { CustomJavascriptCompressor.new }

      it "returns value before to load configuration" do
        @configuration.javascript_compressor.must_equal compressor
      end

      it "returns value after loading" do
        @configuration.js_compressor.must_equal compressor
      end
    end
  end

  describe '#stylesheet_compressor' do
    describe "default" do
      it "is nil by default" do
        @configuration.stylesheet_compressor.must_be_nil
      end

      it "returns NullCompressor when loaded" do
        @configuration.css_compressor.must_be_kind_of Hanami::Assets::Compressors::NullCompressor
      end
    end

    describe "when :yui" do
      before do
        @configuration.stylesheet_compressor :yui
      end

      it "returns value before to load configuration" do
        @configuration.stylesheet_compressor.must_equal :yui
      end

      it "is instance of Hanami::Assets::Compressors::YuiStylesheetCompressor" do
        @configuration.css_compressor.must_be_kind_of Hanami::Assets::Compressors::YuiStylesheet
      end
    end

    describe "when object" do
      before do
        @configuration.stylesheet_compressor compressor
      end

      let(:compressor) { CustomStylesheetCompressor.new }

      it "returns value before to load configuration" do
        @configuration.css_compressor.must_equal compressor
      end

      it "returns value after loading" do
        @configuration.css_compressor.must_equal compressor
      end
    end
  end

  describe '#cdn' do
    it "is false by default" do
      @configuration.cdn.must_equal false
    end

    it 'allows to set a value' do
      @configuration.cdn            true
      @configuration.cdn.must_equal true
    end
  end

  describe '#sources' do
    it "is empty by default" do
      @configuration.sources.must_be_empty
    end

    it "allows to add paths" do
      @configuration.sources << __dir__

      assert @configuration.sources == [__dir__],
        "Expected @configuration.sources to eq [#{ __dir__ }], got #{ @configuration.sources.inspect }"
    end

    it "removes duplicates and nil sources" do
      @configuration.sources << __dir__
      @configuration.sources << __dir__
      @configuration.sources << nil

      assert @configuration.sources == [__dir__],
        "Expected @configuration.sources to eq [#{ __dir__ }], got #{ @configuration.sources.inspect }"
    end
  end

  describe '#scheme' do
    it 'returns "http" as default value' do
      @configuration.scheme.must_equal 'http'
    end

    it 'allows to set a value' do
      @configuration.scheme            'https'
      @configuration.scheme.must_equal 'https'
    end
  end

  describe '#host' do
    it 'returns "localhost" as default value' do
      @configuration.host.must_equal 'localhost'
    end

    it 'allows to set a value' do
      @configuration.host            'hanamirb.org'
      @configuration.host.must_equal 'hanamirb.org'
    end
  end

  describe '#port' do
    it 'returns "2300" as default value' do
      @configuration.port.must_equal '2300'
    end

    it 'allows to set a value (string)' do
      @configuration.port            '443'
      @configuration.port.must_equal '443'
    end

    it 'allows to set a value (integer)' do
      @configuration.port             443
      @configuration.port.must_equal '443'
    end
  end

  describe '#prefix' do
    it 'returns "/assets" value default' do
      @configuration.prefix.must_be_kind_of(Hanami::Utils::PathPrefix)
      @configuration.prefix.must_equal "/assets"
    end

    it 'allows to set a value' do
      @configuration.prefix            'application-prefix'
      @configuration.prefix.must_equal 'application-prefix'
    end
  end

  describe '#public_directory' do
    it 'defaults to "public/" on current directory' do
      expected = Pathname.new(Dir.pwd + '/public')
      @configuration.public_directory.must_equal(expected)
    end

    it 'allows to set a custom location' do
      dest = __dir__ + '/../tmp'
      @configuration.public_directory(dest)
      @configuration.public_directory.must_equal(Pathname.new(File.expand_path(dest)))
    end
  end

  describe '#manifest' do
    it 'defaults to "assets.json"' do
      @configuration.manifest.must_equal 'assets.json'
    end

    it 'allows to set a relative path' do
      @configuration.manifest            'manifest.json'
      @configuration.manifest.must_equal 'manifest.json'
    end
  end

  describe '#manifest_path' do
    it 'joins #manifest with #public_directory' do
      expected = @configuration.public_directory.join(@configuration.manifest)
      @configuration.manifest_path.must_equal expected
    end

    it 'returns absolute path, if #manifest is absolute path' do
      @configuration.manifest expected = __dir__ + '/manifest.json'
      @configuration.manifest_path.must_equal Pathname.new(expected)
    end
  end

  describe '#asset_path' do
    after do
      @configuration.reset!
    end

    it 'returns relative url for given source' do
      actual = @configuration.asset_path('application.js')
      actual.must_equal '/assets/application.js'
    end

    it 'returns String instance' do
      actual = @configuration.asset_path('application.js')
      actual.must_be_kind_of ::String
    end

    describe 'digest mode' do
      before do
        @configuration.digest true
      end

      describe 'with digest manifest' do
        before do
          manifest = Hanami::Assets::Config::DigestManifest.new({'/assets/application.js' => '/assets/application-abc123.js'}, [])
          @configuration.instance_variable_set(:@digest_manifest, manifest)
        end

        it 'returns asset with digest' do
          actual = @configuration.asset_path('application.js')
          actual.must_equal '/assets/application-abc123.js'
        end

        describe 'cdn mode' do
          before do
            @configuration.scheme 'https'
            @configuration.host   'bookshelf.cdn-example.org'
            @configuration.port   '443'
            @configuration.cdn    true

            @configuration.load!
          end

          it 'returns absolute url' do
            actual = @configuration.asset_path('application.js')
            actual.must_equal 'https://bookshelf.cdn-example.org/assets/application-abc123.js'
          end
        end
      end

      describe 'with missing digest manifest' do
        it 'returns asset with digest' do
          exception = -> { @configuration.asset_path('application.js') }.must_raise Hanami::Assets::MissingDigestManifestError
          exception.message.must_equal "Can't read manifest: #{ @configuration.manifest_path }"
        end
      end
    end

    describe 'cdn mode' do
      before do
        @configuration.scheme 'https'
        @configuration.host   'bookshelf.cdn-example.org'
        @configuration.port   '443'
        @configuration.cdn    true

        @configuration.load!
      end

      it 'returns absolute url' do
        actual = @configuration.asset_path('application.js')
        actual.must_equal 'https://bookshelf.cdn-example.org/assets/application.js'
      end
    end
  end

  describe '#asset_url' do
    after do
      @configuration.reset!
    end

    describe 'development mode' do
      before do
        @configuration.load!
      end

      it 'returns absolute url for given source' do
        actual = @configuration.asset_url('application.js')
        actual.must_equal 'http://localhost:2300/assets/application.js'
      end
    end

    describe 'production mode' do
      before do
        @configuration.scheme 'https'
        @configuration.host   'hanamirb.org'
        @configuration.port   443
        @configuration.load!
      end

      it 'returns absolute url for given source' do
        actual = @configuration.asset_url('application.js')
        actual.must_equal 'https://hanamirb.org/assets/application.js'
      end
    end

    describe 'with http scheme' do
      before do
        @configuration.scheme 'http'
      end

      describe 'and standard port' do
        before do
          @configuration.port 80
          @configuration.load!
        end

        it 'returns absolute url without port' do
          actual = @configuration.asset_url('application.js')
          actual.must_equal 'http://localhost/assets/application.js'
        end
      end

      describe 'and custom port' do
        before do
          @configuration.port 8080
          @configuration.load!
        end

        it 'returns absolute url with port' do
          actual = @configuration.asset_url('application.js')
          actual.must_equal 'http://localhost:8080/assets/application.js'
        end
      end
    end

    describe 'with https scheme' do
      before do
        @configuration.scheme 'https'
      end

      describe 'and standard port' do
        before do
          @configuration.port 443
          @configuration.load!
        end

        it 'returns absolute url without port' do
          actual = @configuration.asset_url('application.js')
          actual.must_equal 'https://localhost/assets/application.js'
        end
      end

      describe 'and custom port' do
        before do
          @configuration.port 8081
          @configuration.load!
        end

        it 'returns absolute url with port' do
          actual = @configuration.asset_url('application.js')
          actual.must_equal 'https://localhost:8081/assets/application.js'
        end
      end
    end

    describe 'with custom host' do
      before do
        @configuration.host 'example.com'
        @configuration.load!
      end

      it 'returns absolute url for given source' do
        actual = @configuration.asset_url('application.js')
        actual.must_equal 'http://example.com:2300/assets/application.js'
      end
    end

    describe 'digest mode' do
      before do
        @configuration.digest true
      end

      describe 'with digest manifest' do
        before do
          manifest = Hanami::Assets::Config::DigestManifest.new({'/assets/application.js' => '/assets/application-abc123.js'}, [])

          @configuration.load!
          @configuration.instance_variable_set(:@digest_manifest, manifest)
        end

        it 'returns asset with digest' do
          actual = @configuration.asset_url('application.js')
          actual.must_equal 'http://localhost:2300/assets/application-abc123.js'
        end
      end

      describe 'with missing digest manifest' do
        it 'returns asset with digest' do
          exception = -> { @configuration.asset_url('application.js') }.must_raise Hanami::Assets::MissingDigestManifestError
          exception.message.must_equal "Can't read manifest: #{ @configuration.manifest_path }"
        end
      end
    end
  end

  describe '#reset!' do
    before do
      @configuration.scheme 'https'
      @configuration.host   'example.com'
      @configuration.port   '443'
      @configuration.prefix 'prfx'
      @configuration.javascript_compressor :yui
      @configuration.stylesheet_compressor :yui
      @configuration.manifest 'assets.json'
      @configuration.public_directory(Dir.pwd + '/tmp')
      @configuration.instance_variable_set(:@digest_manifest, {})

      @configuration.reset!
    end

    it 'sets default value for public directory' do
      @configuration.public_directory.must_equal(Pathname.new(Dir.pwd + '/public'))
    end

    it 'sets default value for scheme' do
      @configuration.scheme.must_equal('http')
    end

    it 'sets default value for host' do
      @configuration.host.must_equal('localhost')
    end

    it 'sets default value for port' do
      @configuration.port.must_equal('2300')
    end

    it 'sets default value for prefix' do
      @configuration.prefix.must_be_kind_of(Hanami::Utils::PathPrefix)
      @configuration.prefix.must_equal '/assets'
    end

    it 'sets default value for javascript_compressor' do
      @configuration.javascript_compressor.must_be_nil
    end

    it 'sets default value for stylesheet_compressor' do
      @configuration.stylesheet_compressor.must_be_nil
    end

    it 'sets default value for manifest' do
      @configuration.manifest.must_equal('assets.json')
    end

    it 'sets default value fore digest manifest' do
      assert @configuration.digest_manifest.class == Hanami::Assets::Config::NullDigestManifest,
        "Expected @configuration.digest_manifest to be instance of Hanami::Assets::Configuration::NullDigestManifest"
    end
  end

  describe '#duplicate' do
    before do
      @configuration.reset!
      @configuration.cdn                   true
      @configuration.compile               true
      @configuration.scheme                'ftp'
      @configuration.host                  'hanamirb.org'
      @configuration.port                  '8080'
      @configuration.prefix                '/foo'
      @configuration.manifest              'm.json'
      @configuration.javascript_compressor :yui
      @configuration.stylesheet_compressor :yui
      @configuration.root                  __dir__
      @configuration.public_directory      __dir__
      @configuration.sources            << __dir__ + '/fixtures/javascripts'

      @config = @configuration.duplicate
    end

    it 'returns a copy of the configuration' do
      @config.cdn.must_equal                   true
      @config.compile.must_equal               true
      @config.scheme.must_equal                'ftp'
      @config.host.must_equal                  'hanamirb.org'
      @config.port.must_equal                  '8080'
      @config.prefix.must_equal                '/foo'
      @config.manifest.must_equal              'm.json'
      @config.javascript_compressor.must_equal :yui
      @config.stylesheet_compressor.must_equal :yui
      @config.root.must_equal                  Pathname.new(__dir__)
      @config.public_directory.must_equal      Pathname.new(__dir__)
      assert @config.sources == [__dir__ + '/fixtures/javascripts'],
        "Expected #{ @config.sources } to eq [#{ __dir__ }/fixtures/javascripts'], found: #{ @config.sources.inspect }"
    end

    it "doesn't affect the original configuration" do
      @config.cdn                   false
      @config.compile               false
      @config.scheme                'mailto'
      @config.host                  'example.org'
      @config.port                  '9091'
      @config.prefix                '/bar'
      @config.manifest              'a.json'
      @config.javascript_compressor :uglify
      @config.stylesheet_compressor :uglify
      @config.root                  __dir__ + '/fixtures'
      @config.public_directory      __dir__ + '/fixtures'
      @config.sources << __dir__ + '/fixtures/stylesheets'

      @config.cdn.must_equal                   false
      @config.compile.must_equal               false
      @config.scheme.must_equal                'mailto'
      @config.host.must_equal                  'example.org'
      @config.port.must_equal                  '9091'
      @config.prefix.must_equal                '/bar'
      @config.manifest.must_equal              'a.json'
      @config.javascript_compressor.must_equal :uglify
      @config.stylesheet_compressor.must_equal :uglify
      @config.root.must_equal                  Pathname.new(__dir__ + '/fixtures')
      @config.public_directory.must_equal      Pathname.new(__dir__ + '/fixtures')
      assert @config.sources == [__dir__ + '/fixtures/javascripts', __dir__ + '/fixtures/stylesheets'],
        "Expected @config.sources to eq [#{ __dir__ }/fixtures/javascripts', #{ __dir__ }/fixtures/stylesheets'], found: #{ @config.sources.inspect }"

      @configuration.cdn.must_equal                   true
      @configuration.compile.must_equal               true
      @configuration.scheme.must_equal                'ftp'
      @configuration.host.must_equal                  'hanamirb.org'
      @configuration.port.must_equal                  '8080'
      @configuration.prefix.must_equal                '/foo'
      @configuration.manifest.must_equal              'm.json'
      @configuration.javascript_compressor.must_equal :yui
      @configuration.stylesheet_compressor.must_equal :yui
      @configuration.root.must_equal                  Pathname.new(__dir__)
      @configuration.public_directory.must_equal      Pathname.new(__dir__)
      assert @configuration.sources == [__dir__ + '/fixtures/javascripts'],
        "Expected @config.sources to eq [#{ __dir__ }/fixtures/javascripts'], found: #{ @config.sources.inspect }"
    end
  end
end
