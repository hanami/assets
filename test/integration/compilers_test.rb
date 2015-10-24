require 'test_helper'
require 'tilt/sass'
require 'tilt/coffee'

describe 'Compilers' do
  before do
    fixtures = __dir__ + '/../fixtures'
    TMP.rmtree if TMP.exist?

    Lotus::Assets.configure do
      compile     true
      root        fixtures
      destination TMP.join('public/assets')

      sources << [
        'javascripts',
        Pathname.new(fixtures).join('stylesheets')
      ]
    end

    @config = Lotus::Assets.configuration
  end

  after do
    @config.reset!
  end

  it 'copies javascript asset from source to destination' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/greet.js" type="text/javascript"></script>)

    target = @config.destination.join('greet.js')
    target.read.must_match %(alert("Hello!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'copies asset from nested source to destination' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/bootstrap.js" type="text/javascript"></script>)

    target = @config.destination.join('bootstrap.js')
    target.read.must_match %(// Bootstrap)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles coffeescript asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/hello.js" type="text/javascript"></script>)

    target = @config.destination.join('hello.js')
    target.read.must_match %(alert("Hello, World!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles es6 asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/person.js" type="text/javascript"></script>)

    target = @config.destination.join('person.js')
    target.read.must_match %(function Person(firstName, lastName))
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles babel asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/country.js" type="text/javascript"></script>)

    target = @config.destination.join('country.js')
    target.read.must_match %(function Country(name))
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles jsx asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/react-component.js" type="text/javascript"></script>)

    target = @config.destination.join('react-component.js')
    target.read.must_match %(React.createElement(MyComponent, { someProperty: true });)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles sass asset' do
    result = CssCompilerView.new.render
    result.must_include %(<link href="/assets/compile-sass.css" type="text/css" rel="stylesheet">)

    target = @config.destination.join('compile-sass.css')
    target.read.must_match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #333; }\n)
  end

  it 'compiles scss asset' do
    result = CssCompilerView.new.render
    result.must_include %(<link href="/assets/compile-scss.css" type="text/css" rel="stylesheet">)

    target = @config.destination.join('compile-scss.css')
    target.read.must_match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #fff; }\n)
  end

  it "won't compile/copy if the source hasn't changed" do
    result = UnchangedCompilerView.new.render
    result.must_include %(<script src="/assets/unchanged.js" type="text/javascript"></script>)

    compiled    = @config.destination.join('unchanged.js')
    content     = compiled.read
    modified_at = compiled.mtime

    content.must_match %(alert("Still the same");)

    sleep 1

    UnchangedCompilerView.new.render
    compiled = @config.destination.join('unchanged.js')

    compiled.read.must_match %(alert("Still the same");)
    compiled.mtime.to_i.must_equal modified_at.to_i
  end

  it 'raises an error in case of missing source' do
    sources   = @config.sources.map(&:to_s).join(', ')
    exception = -> { MissingAssetSourceView.new.render }.must_raise(Lotus::Assets::MissingAsset)

    exception.message.must_equal("Missing asset: `missing.js' (sources: #{ sources })")
  end

  it 'raises an error in case of unknown compiler engine' do
    exception = -> { UnknownAssetEngineView.new.render }.must_raise(Lotus::Assets::UnknownAssetEngine)
    exception.message.must_equal("No asset engine registered for `ouch.js.unknown'")
  end

  it 'ignores hidden files beginning with a dot (.)' do
    proc { HiddenAssetCompilerView.new.render }.must_raise(Lotus::Assets::MissingAsset)
  end
end
