require 'test_helper'

describe 'Rendering test' do
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
      @result = CustomAssetsPathView.new.render
    end

    it 'resolves javascript tag under configured path' do
      @result.must_include %(<script src="/custom-assets-path/feature-a.js" type="text/javascript"></script>)
    end

    it 'resolves stylesheet tag under configured path' do
      @result.must_include %(<link href="/custom-assets-path-for-css/main.css" type="text/css" rel="stylesheet">)
    end
  end
end
