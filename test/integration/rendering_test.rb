require 'test_helper'

describe 'Rendering test' do
  before do
    @result = View.new.render
  end

  it 'resolves javascript tag' do
    @result.must_include %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
  end

  it 'resolves stylesheet tag' do
    @result.must_include %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
  end
end
