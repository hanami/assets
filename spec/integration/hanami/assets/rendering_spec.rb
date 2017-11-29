# frozen_string_literal: true

describe "Rendering test" do
  before do
    Hanami::Assets.configuration.reset!
  end

  after do
    Hanami::Assets.configuration.reset!
    Thread.current[:__hanami_assets] = nil
  end

  describe "with defaults" do
    let(:result) { DefaultView.new.render }

    it "resolves javascript tag" do
      expect(result).to include %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
    end

    it "resolves stylesheet tag" do
      expect(result).to include %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
    end

    it "stores assets in thread local" do
      result
      assets = Thread.current[:__hanami_assets]
      expect(assets).to be_kind_of(Hash)
      expect(assets.fetch("/assets/main.css")).to eq(as: :style, crossorigin: false)
      expect(assets.fetch("/assets/feature-a.js")).to eq(as: :script, crossorigin: false)
    end
  end

  describe "with custom assets prefix" do
    let(:result) { CustomAssetsPrefix.new.render }
    before do
      Hanami::Assets.configure do
        prefix "/assets/prefix"
      end
    end

    it "resolves javascript tag under configured path" do
      expect(result).to include %(<script src="/assets/prefix/feature-a.js" type="text/javascript"></script>)
    end

    it "resolves stylesheet tag under configured path" do
      expect(result).to include %(<link href="/assets/prefix/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe "with multiple assets" do
    let(:result) { RenderMultipleAssets.new.render }

    it "resolves javascript tags" do
      expect(result).to include %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
      expect(result).to include %(<script src="/assets/feature-b.js" type="text/javascript"></script>)
    end

    it "resolves stylesheets tag" do
      expect(result).to include %(<link href="/assets/grid.css" type="text/css" rel="stylesheet">)
      expect(result).to include %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe "with absolute url" do
    before do
      Hanami::Assets.configuration.load!
    end

    let(:result) { AbsoluteUrlsView.new.render }

    it "resolves javascript tag" do
      expect(result).to include %(<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js" type="text/javascript"></script>)
    end

    it "resolves stylesheets tag" do
      expect(result).to include %(<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" type="text/css" rel="stylesheet">)
    end
  end

  describe "with assets that need to be preprocessed" do
    describe "javascripts" do
      let(:result) { CompilerView.new.render }

      it "renders script tag for pure javascript source file" do
        expect(result).to include %(<script src="/assets/greet.js" type="text/javascript"></script>)
      end

      it "renders script tag for pure javascript source file from nested path" do
        expect(result).to include %(<script src="/assets/bootstrap.js" type="text/javascript"></script>)
      end

      it "renders script tag for coffeescript source file from nested path" do
        expect(result).to include %(<script src="/assets/hello.js" type="text/javascript"></script>)
      end

      it "renders script tag for es6 source file from nested path" do
        expect(result).to include %(<script src="/assets/person.js" type="text/javascript"></script>)
      end

      it "renders script tag for babel source file from nested path" do
        expect(result).to include %(<script src="/assets/country.js" type="text/javascript"></script>)
      end

      it "renders script tag for jsx source file from nested path" do
        expect(result).to include %(<script src="/assets/react-component.js" type="text/javascript"></script>)
      end
    end

    describe "stylesheets" do
      let(:result) { CssCompilerView.new.render }

      it "renders link tag for sass source file" do
        expect(result).to include %(<link href="/assets/compile-sass.css" type="text/css" rel="stylesheet">)
      end

      it "renders link tag for scss source file" do
        expect(result).to include %(<link href="/assets/compile-scss.css" type="text/css" rel="stylesheet">)
      end
    end

    describe "unknown engine" do
      it "doesn't raise error but still render it" do
        result = UnknownAssetEngineView.new.render
        expect(result).to include %(<script src="/assets/ouch.js" type="text/javascript"></script>)
      end
    end
  end

  describe "missing assets" do
    it "doesn't raise error but still render it" do
      result = MissingAssetSourceView.new.render
      expect(result).to include %(<script src="/assets/missing.js" type="text/javascript"></script>)
    end
  end
end
