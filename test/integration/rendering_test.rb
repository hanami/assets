require 'test_helper'

describe 'Rendering test' do
  before do
    Lotus::Assets.configuration.reset!
  end

  describe 'with defaults' do
    before do
      @result = DefaultView.new.render
    end

    it 'resolves javascript tag' do
      @result.must_include %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheet tag' do
      @result.must_include %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe 'with custom assets path' do
    before do
      Lotus::Assets.configure do
        define :javascript do
          path 'custom-assets-path'
        end

        define :stylesheet do
          path 'custom-assets-path-for-css'
        end
      end

      @result = CustomAssetsPathView.new.render
    end

    it 'resolves javascript tag under configured path' do
      @result.must_include %(<script src="/custom-assets-path/feature-a.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheet tag under configured path' do
      @result.must_include %(<link href="/custom-assets-path-for-css/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe 'with custom assets prefix' do
    before do
      Lotus::Assets.configure do
        prefix 'prefix' # FIXME '/prefix'
      end

      @result = CustomAssetsPrefix.new.render
    end

    it 'resolves javascript tag under configured path' do
      @result.must_include %(<script src="/prefix/assets/feature-a.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheet tag under configured path' do
      @result.must_include %(<link href="/prefix/assets/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe 'with multiple assets' do
    before do
      @result = RenderMultipleAssets.new.render
    end

    it 'resolves javascript tags' do
      @result.must_include %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
      @result.must_include %(<script src="/assets/feature-b.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheets tag' do
      @result.must_include %(<link href="/assets/grid.css" type="text/css" rel="stylesheet">)
      @result.must_include %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
    end
  end

  describe 'with absolute url' do
    before do
      @result = AbsoluteUrlsView.new.render
    end

    it 'resolves javascript tag' do
      @result.must_include %(<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheets tag' do
      @result.must_include %(<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" type="text/css" rel="stylesheet">)
    end
  end
end
