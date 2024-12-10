# frozen_string_literal: true

require "hanami/assets/compressors/javascript"
require "hanami/assets/compressors/stylesheet"

RSpec.describe Hanami::Assets::Configuration do
  before do
    @configuration = Hanami::Assets::Configuration.new
  end

  after do
    @configuration.reset!
  end

  describe "#javascript_compressor" do
    describe "default" do
      it "is nil by default" do
        expect(@configuration.javascript_compressor).to be_nil
      end

      it "returns NullCompressor for internal usage" do
        expect(@configuration.js_compressor).to be_kind_of(Hanami::Assets::Compressors::NullCompressor)
      end
    end

    describe "when :yui" do
      before do
        @configuration.javascript_compressor :yui
      end

      it "returns value before to load configuration" do
        expect(@configuration.javascript_compressor).to eq(:yui)
      end

      it "is instance of Hanami::Assets::Compressors::YuiJavascriptCompressor" do
        expect(@configuration.js_compressor).to be_kind_of(Hanami::Assets::Compressors::YuiJavascript)
      end
    end

    describe "when object" do
      before do
        @configuration.javascript_compressor compressor
      end

      let(:compressor) { CustomJavascriptCompressor.new }

      it "returns value before to load configuration" do
        expect(@configuration.javascript_compressor).to eq(compressor)
      end

      it "returns value after loading" do
        expect(@configuration.js_compressor).to eq(compressor)
      end
    end
  end

  describe "#stylesheet_compressor" do
    describe "default" do
      it "is nil by default" do
        expect(@configuration.stylesheet_compressor).to be_nil
      end

      it "returns NullCompressor when loaded" do
        expect(@configuration.css_compressor).to be_kind_of(Hanami::Assets::Compressors::NullCompressor)
      end
    end

    describe "when :yui" do
      before do
        @configuration.stylesheet_compressor :yui
      end

      it "returns value before to load configuration" do
        expect(@configuration.stylesheet_compressor).to eq(:yui)
      end

      it "is instance of Hanami::Assets::Compressors::YuiStylesheetCompressor" do
        expect(@configuration.css_compressor).to be_kind_of(Hanami::Assets::Compressors::YuiStylesheet)
      end
    end

    describe "when object" do
      before do
        @configuration.stylesheet_compressor compressor
      end

      let(:compressor) { CustomStylesheetCompressor.new }

      it "returns value before to load configuration" do
        expect(@configuration.css_compressor).to eq(compressor)
      end

      it "returns value after loading" do
        expect(@configuration.css_compressor).to eq(compressor)
      end
    end
  end

  describe "#subresource_integrity" do
    it "is false by default" do
      expect(@configuration.subresource_integrity).to eq(false)
    end

    it "allows to set to true, with default of SHA256" do
      @configuration.subresource_integrity true
      expect(@configuration.subresource_integrity).to eq(true)
    end

    it "allows to set a symbol" do
      @configuration.subresource_integrity :sha384
      expect(@configuration.subresource_integrity).to eq(:sha384)
    end

    it "allows to set an Array of symbols, without brackets" do
      @configuration.subresource_integrity :sha256, :sha512
      expect(@configuration.subresource_integrity).to eq(%i[sha256 sha512])
    end

    it "allows to set an Array of symbols, with brackets" do
      @configuration.subresource_integrity %i[sha256 sha512]
      expect(@configuration.subresource_integrity).to eq(%i[sha256 sha512])
    end
  end

  describe "#subresource_integrity_algorithms" do
    it "includes only sha256 by default" do
      @configuration.subresource_integrity true
      expect(@configuration.subresource_integrity_algorithms).to eq([:sha256])
    end

    it "converts symbol into array of symboles" do
      @configuration.subresource_integrity :sha384
      expect(@configuration.subresource_integrity_algorithms).to eq([:sha384])
    end

    it "allows to an Array of symbols" do
      @configuration.subresource_integrity %i[sha256 sha512]
      expect(@configuration.subresource_integrity_algorithms).to eq(%i[sha256 sha512])
    end
  end

  describe "#cdn" do
    it "is false by default" do
      expect(@configuration.cdn).to eq(false)
    end

    it "allows to set a value" do
      @configuration.cdn               true
      expect(@configuration.cdn).to eq(true)
    end
  end

  describe "#nested" do
    it "is false by default" do
      expect(@configuration.nested).to eq(false)
    end

    it "allows to set a value" do
      @configuration.nested               true
      expect(@configuration.nested).to eq(true)
    end
  end

  describe "#sources" do
    it "is empty by default" do
      expect(@configuration.sources).to be_empty
    end

    it "allows to add paths" do
      @configuration.sources << __dir__

      expect(@configuration.sources).to eq([__dir__])
    end

    it "removes duplicates and nil sources" do
      @configuration.sources << __dir__
      @configuration.sources << __dir__
      @configuration.sources << nil

      expect(@configuration.sources).to eq([__dir__])
    end
  end

  describe "#scheme" do
    it 'returns "http" as default value' do
      expect(@configuration.scheme).to eq("http")
    end

    it "allows to set a value" do
      @configuration.scheme               "https"
      expect(@configuration.scheme).to eq("https")
    end
  end

  describe "#host" do
    it 'returns "localhost" as default value' do
      expect(@configuration.host).to eq("localhost")
    end

    it "allows to set a value" do
      @configuration.host               "hanamirb.org"
      expect(@configuration.host).to eq("hanamirb.org")
    end
  end

  describe "#port" do
    it 'returns "2300" as default value' do
      expect(@configuration.port).to eq("2300")
    end

    it "allows to set a value (string)" do
      @configuration.port               "443"
      expect(@configuration.port).to eq("443")
    end

    it "allows to set a value (integer)" do
      @configuration.port                443
      expect(@configuration.port).to eq("443")
    end
  end

  describe "#prefix" do
    it 'returns "/assets" value default' do
      expect(@configuration.prefix).to be_kind_of(Hanami::CygUtils::PathPrefix)
      expect(@configuration.prefix).to eq("/assets")
    end

    it "allows to set a value" do
      @configuration.prefix               "application-prefix"
      expect(@configuration.prefix).to eq("application-prefix")
    end
  end

  describe "#public_directory" do
    it 'defaults to "public/" on current directory' do
      expected = Pathname.new(Dir.pwd + "/public")
      expect(@configuration.public_directory).to eq(expected)
    end

    it "allows to set a custom location" do
      dest = __dir__ + "/../tmp"
      @configuration.public_directory(dest)
      expect(@configuration.public_directory).to eq(Pathname.new(File.expand_path(dest)))
    end
  end

  describe "#manifest" do
    it 'defaults to "assets.json"' do
      expect(@configuration.manifest).to eq("assets.json")
    end

    it "allows to set a relative path" do
      @configuration.manifest               "manifest.json"
      expect(@configuration.manifest).to eq("manifest.json")
    end
  end

  describe "#manifest_path" do
    it "joins #manifest with #public_directory" do
      expected = @configuration.public_directory.join(@configuration.manifest)
      expect(@configuration.manifest_path).to eq(expected)
    end

    it "returns absolute path, if #manifest is absolute path" do
      @configuration.manifest expected = __dir__ + "/manifest.json"
      expect(@configuration.manifest_path).to eq(Pathname.new(expected))
    end
  end

  describe "#asset_path" do
    after do
      @configuration.reset!
    end

    it "returns relative url for given source" do
      actual = @configuration.asset_path("application.js")
      expect(actual).to eq("/assets/application.js")
    end

    it "returns String instance" do
      actual = @configuration.asset_path("application.js")
      expect(actual).to be_kind_of(::String)
    end

    describe "fingerprint mode" do
      before do
        @configuration.fingerprint true
      end

      describe "with manifest" do
        before do
          manifest = Hanami::Assets::Config::Manifest.new({
                                                            "/assets/application.js" => {
                                                              "target" => "/assets/application-abc123.js"
                                                            }
                                                          }, [])
          @configuration.instance_variable_set(:@public_manifest, manifest)
        end

        it "returns asset with fingerprint" do
          actual = @configuration.asset_path("application.js")
          expect(actual).to eq("/assets/application-abc123.js")
        end

        describe "cdn mode" do
          before do
            @configuration.scheme "https"
            @configuration.host   "bookshelf.cdn-example.org"
            @configuration.port   "443"
            @configuration.cdn    true

            @configuration.load!
          end

          it "returns absolute url" do
            actual = @configuration.asset_path("application.js")
            expect(actual).to eq("https://bookshelf.cdn-example.org/assets/application-abc123.js")
          end
        end
      end

      describe "with missing manifest" do
        it "raises exception with correct message" do
          expect do
            @configuration.asset_path("application.js")
          end.to raise_error(Hanami::Assets::MissingManifestFileError,
                             "Can't read manifest: #{@configuration.manifest_path}")
        end
      end
    end

    describe "cdn mode" do
      before do
        @configuration.scheme "https"
        @configuration.host   "bookshelf.cdn-example.org"
        @configuration.port   "443"
        @configuration.cdn    true

        @configuration.load!
      end

      it "returns absolute url" do
        actual = @configuration.asset_path("application.js")
        expect(actual).to eq("https://bookshelf.cdn-example.org/assets/application.js")
      end
    end
  end

  describe "#asset_url" do
    after do
      @configuration.reset!
    end

    describe "development mode" do
      before do
        @configuration.load!
      end

      it "returns absolute url for given source" do
        actual = @configuration.asset_url("application.js")
        expect(actual).to eq("http://localhost:2300/assets/application.js")
      end
    end

    describe "production mode" do
      before do
        @configuration.scheme "https"
        @configuration.host   "hanamirb.org"
        @configuration.port   443
        @configuration.load!
      end

      it "returns absolute url for given source" do
        actual = @configuration.asset_url("application.js")
        expect(actual).to eq("https://hanamirb.org/assets/application.js")
      end
    end

    describe "with http scheme" do
      before do
        @configuration.scheme "http"
      end

      describe "and standard port" do
        before do
          @configuration.port 80
          @configuration.load!
        end

        it "returns absolute url without port" do
          actual = @configuration.asset_url("application.js")
          expect(actual).to eq("http://localhost/assets/application.js")
        end
      end

      describe "and custom port" do
        before do
          @configuration.port 8080
          @configuration.load!
        end

        it "returns absolute url with port" do
          actual = @configuration.asset_url("application.js")
          expect(actual).to eq("http://localhost:8080/assets/application.js")
        end
      end
    end

    describe "with https scheme" do
      before do
        @configuration.scheme "https"
      end

      describe "and standard port" do
        before do
          @configuration.port 443
          @configuration.load!
        end

        it "returns absolute url without port" do
          actual = @configuration.asset_url("application.js")
          expect(actual).to eq("https://localhost/assets/application.js")
        end
      end

      describe "and custom port" do
        before do
          @configuration.port 8081
          @configuration.load!
        end

        it "returns absolute url with port" do
          actual = @configuration.asset_url("application.js")
          expect(actual).to eq("https://localhost:8081/assets/application.js")
        end
      end
    end

    describe "with custom host" do
      before do
        @configuration.host "example.com"
        @configuration.load!
      end

      it "returns absolute url for given source" do
        actual = @configuration.asset_url("application.js")
        expect(actual).to eq("http://example.com:2300/assets/application.js")
      end
    end

    describe "fingerprint mode" do
      before do
        @configuration.fingerprint true
      end

      describe "with manifest" do
        before do
          manifest = Hanami::Assets::Config::Manifest.new({"/assets/application.js" => {"target" => "/assets/application-abc123.js"}}, [])

          @configuration.load!
          @configuration.instance_variable_set(:@public_manifest, manifest)
        end

        it "returns asset with fingerprint" do
          actual = @configuration.asset_url("application.js")
          expect(actual).to eq("http://localhost:2300/assets/application-abc123.js")
        end
      end

      describe "with missing manifest" do
        it "raises exception with correct message" do
          expect do
            @configuration.asset_url("application.js")
          end.to raise_error(Hanami::Assets::MissingManifestFileError,
                             "Can't read manifest: #{@configuration.manifest_path}")
        end
      end
    end
  end

  describe "#crossorigin?" do
    after do
      @configuration.reset!
    end

    context "development mode" do
      before do
        @configuration.load!
      end

      it "returns false when scheme, host, and port match" do
        expect(@configuration.crossorigin?("http://localhost:2300/assets/application.js")).to be(false)
      end

      it "returns true when scheme doesn't match" do
        expect(@configuration.crossorigin?("https://localhost:2300/assets/application.js")).to be(true)
      end

      it "returns true when host doesn't match" do
        expect(@configuration.crossorigin?("http://some-host:2300/assets/application.js")).to be(true)
      end

      it "returns true when uses a subdomain" do
        expect(@configuration.crossorigin?("http://assets.localhost:2300/assets/application.js")).to be(true)
      end

      it "returns true when port doesn't match" do
        expect(@configuration.crossorigin?("http://localhost:8080/assets/application.js")).to be(true)
      end
    end

    describe "production mode" do
      before do
        @configuration.scheme "https"
        @configuration.host   "hanamirb.org"
        @configuration.port   443
        @configuration.load!
      end

      it "returns false when scheme, host, and port match" do
        expect(@configuration.crossorigin?("https://hanamirb.org/assets/application.js")).to be(false)
      end

      it "returns true when scheme doesn't match" do
        expect(@configuration.crossorigin?("http://hanamirb.org/assets/application.js")).to be(true)
      end

      it "returns true when host doesn't match" do
        expect(@configuration.crossorigin?("https://hanamirb.test/assets/application.js")).to be(true)
      end

      it "returns true when uses a subdomain" do
        expect(@configuration.crossorigin?("https://www.hanamirb.org/assets/application.js")).to be(true)
      end

      xit "returns true when port doesn't match" do
        @configuration.crossorigin?("https://hanamirb.org:8081/assets/application.js")
        expect(@configuration.crossorigin?("https://hanamirb.org:8081/assets/application.js")).to be(true)
      end
    end
  end

  describe "subresource_integrity_value" do
    describe "subresource_integrity mode" do
      before do
        @configuration.subresource_integrity true
      end

      describe "with manifest" do
        before do
          manifest = Hanami::Assets::Config::Manifest.new({
                                                            "/assets/application.js" => {
                                                              "target" => "/assets/application-abc123.js",
                                                              "sri" => ["sha0-456def"]
                                                            }
                                                          }, [])

          @configuration.load!
          @configuration.instance_variable_set(:@public_manifest, manifest)
        end

        it "returns subresource_integrity value" do
          actual = @configuration.subresource_integrity_value("application.js")
          expect(actual).to eq("sha0-456def")
        end
      end

      describe "with missing manifest" do
        it "raises an exception" do
          expect do
            @configuration.subresource_integrity_value("application.js")
          end.to raise_error(Hanami::Assets::MissingManifestFileError,
                             "Can't read manifest: #{@configuration.manifest_path}")
        end
      end
    end
  end

  describe "#reset!" do
    before do
      @configuration.scheme "https"
      @configuration.host   "example.com"
      @configuration.port   "443"
      @configuration.prefix "prfx"
      @configuration.javascript_compressor :yui
      @configuration.stylesheet_compressor :yui
      @configuration.manifest "assets.json"
      @configuration.public_directory(Dir.pwd + "/tmp")
      @configuration.instance_variable_set(:@public_manifest, {})

      @configuration.reset!
    end

    it "sets default value for public directory" do
      expect(@configuration.public_directory).to eq(Pathname.new(Dir.pwd + "/public"))
    end

    it "sets default value for scheme" do
      expect(@configuration.scheme).to eq("http")
    end

    it "sets default value for host" do
      expect(@configuration.host).to eq("localhost")
    end

    it "sets default value for port" do
      expect(@configuration.port).to eq("2300")
    end

    it "sets default value for prefix" do
      expect(@configuration.prefix).to be_kind_of(Hanami::CygUtils::PathPrefix)
      expect(@configuration.prefix).to eq("/assets")
    end

    it "sets default value for javascript_compressor" do
      expect(@configuration.javascript_compressor).to be_nil
    end

    it "sets default value for stylesheet_compressor" do
      expect(@configuration.stylesheet_compressor).to be_nil
    end

    it "sets default value for manifest" do
      expect(@configuration.manifest).to eq("assets.json")
    end

    it "sets default value for manifest" do
      expect(@configuration.public_manifest.class).to eq(Hanami::Assets::Config::NullManifest)
    end
  end

  describe "#duplicate" do
    before do
      @configuration.reset!
      @configuration.cdn                   true
      @configuration.subresource_integrity true
      @configuration.compile               true
      @configuration.nested                true
      @configuration.scheme                "ftp"
      @configuration.host                  "hanamirb.org"
      @configuration.port                  "8080"
      @configuration.prefix                "/foo"
      @configuration.manifest              "m.json"
      @configuration.javascript_compressor :yui
      @configuration.stylesheet_compressor :yui
      @configuration.root                  __dir__
      @configuration.public_directory      __dir__
      @configuration.sources << __dir__ + "/fixtures/javascripts"

      @config = @configuration.duplicate
    end

    it "returns a copy of the configuration" do
      expect(@config.cdn).to                   eq(true)
      expect(@config.subresource_integrity).to eq(true)
      expect(@config.compile).to               eq(true)
      expect(@config.nested).to                eq(true)
      expect(@config.scheme).to                eq("ftp")
      expect(@config.host).to                  eq("hanamirb.org")
      expect(@config.port).to                  eq("8080")
      expect(@config.prefix).to                eq("/foo")
      expect(@config.manifest).to              eq("m.json")
      expect(@config.javascript_compressor).to eq(:yui)
      expect(@config.stylesheet_compressor).to eq(:yui)
      expect(@config.root).to                  eq(Pathname.new(__dir__))
      expect(@config.public_directory).to      eq(Pathname.new(__dir__))
      expect(@config.sources).to               eq([__dir__ + "/fixtures/javascripts"])
    end

    it "doesn't affect the original configuration" do
      @config.cdn                   false
      @config.subresource_integrity false
      @config.compile               false
      @config.nested                false
      @config.scheme                "mailto"
      @config.host                  "example.org"
      @config.port                  "9091"
      @config.prefix                "/bar"
      @config.manifest              "a.json"
      @config.javascript_compressor :uglify
      @config.stylesheet_compressor :uglify
      @config.root                  __dir__ + "/../../../support/fixtures"
      @config.public_directory      __dir__ + "/fixtures"
      @config.sources << __dir__ + "/fixtures/stylesheets"

      expect(@config.cdn).to                   eq(false)
      expect(@config.subresource_integrity).to eq(false)
      expect(@config.compile).to               eq(false)
      expect(@config.nested).to                eq(false)
      expect(@config.scheme).to                eq("mailto")
      expect(@config.host).to                  eq("example.org")
      expect(@config.port).to                  eq("9091")
      expect(@config.prefix).to                eq("/bar")
      expect(@config.manifest).to              eq("a.json")
      expect(@config.javascript_compressor).to eq(:uglify)
      expect(@config.stylesheet_compressor).to eq(:uglify)
      expect(@config.root).to                  eq(Pathname.new(File.expand_path(__dir__ + "/../../../support/fixtures")))
      expect(@config.public_directory).to      eq(Pathname.new(__dir__ + "/fixtures"))
      expect(@config.sources).to eq([__dir__ + "/fixtures/javascripts", __dir__ + "/fixtures/stylesheets"])

      expect(@configuration.cdn).to                   eq(true)
      expect(@configuration.subresource_integrity).to eq(true)
      expect(@configuration.compile).to               eq(true)
      expect(@configuration.nested).to                eq(true)
      expect(@configuration.scheme).to                eq("ftp")
      expect(@configuration.host).to                  eq("hanamirb.org")
      expect(@configuration.port).to                  eq("8080")
      expect(@configuration.prefix).to                eq("/foo")
      expect(@configuration.manifest).to              eq("m.json")
      expect(@configuration.javascript_compressor).to eq(:yui)
      expect(@configuration.stylesheet_compressor).to eq(:yui)
      expect(@configuration.root).to                  eq(Pathname.new(__dir__))
      expect(@configuration.public_directory).to      eq(Pathname.new(__dir__))
      expect(@configuration.sources).to eq([__dir__ + "/fixtures/javascripts"])
    end
  end
end
