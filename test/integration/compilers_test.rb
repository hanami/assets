require 'test_helper'
require 'tilt/sass'
require 'tilt/coffee'

describe 'Compilers' do
  before do
    fixtures = __dir__ + '/../fixtures'
    tmp      = Pathname.new(__dir__ + '/../../tmp')
    tmp.rmtree if tmp.exist?

    Lotus::Assets.configure do
      compile     true
      root        fixtures
      destination tmp.join('public')

      define :javascript do
        sources << [
          'javascripts'
        ]
      end

      define :stylesheet do
        sources << [
          Pathname.new(fixtures).join('stylesheets')
        ]
      end
    end

    @config = Lotus::Assets.configuration
  end

  after do
    @config.reset!
  end

  it 'copies javascript asset from source to destination' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/greet.js" type="text/javascript"></script>)

    target = @config.destination.join('assets/greet.js')
    target.read.must_match %(alert("Hello!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles coffeescript asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/hello.js" type="text/javascript"></script>)

    target = @config.destination.join('assets/hello.js')
    target.read.must_match %(alert("Hello, World!");)
    target.stat.mode.to_s(8).must_equal('100644')
  end

  it 'compiles sass asset' do
    result = CssCompilerView.new.render
    result.must_include %(<link href="/assets/compile-sass.css" type="text/css" rel="stylesheet">)

    target = @config.destination.join('assets/compile-sass.css')
    target.read.must_match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #333; }\n)
  end

  it 'compiles scss asset' do
    result = CssCompilerView.new.render
    result.must_include %(<link href="/assets/compile-scss.css" type="text/css" rel="stylesheet">)

    target = @config.destination.join('assets/compile-scss.css')
    target.read.must_match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #fff; }\n)
  end

  it "won't compile/copy if the source hasn't changed" do
    result = UnchangedCompilerView.new.render
    result.must_include %(<script src="/assets/unchanged.js" type="text/javascript"></script>)

    compiled    = @config.destination.join('assets/unchanged.js')
    content     = compiled.read
    modified_at = compiled.mtime

    content.must_match %(alert("Still the same");)

    sleep 1

    UnchangedCompilerView.new.render
    compiled = @config.destination.join('assets/unchanged.js')

    compiled.read.must_match %(alert("Still the same");)
    compiled.mtime.to_i.must_equal modified_at.to_i
  end

  it 'raises an error in case of missing source' do
    sources   = @config.asset(:javascript).sources.map(&:to_s).join(', ')
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
