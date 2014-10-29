require 'test_helper'

describe 'Compilers' do
  before do
    root = __dir__ + '/../fixtures'
    tmp  = Pathname.new(__dir__ + '/../../tmp')
    tmp.rmtree

    Lotus::Assets.configure do
      compile     true
      destination tmp.join('public')

      define :javascript do
        sources << [
          "#{ root }/javascripts"
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

    compiled = @config.destination.join('assets/greet.js').read
    compiled.must_match %(alert("Hello!");)
  end

  it 'compiles coffeescript asset' do
    result = CompilerView.new.render
    result.must_include %(<script src="/assets/hello.js" type="text/javascript"></script>)

    compiled = @config.destination.join('assets/hello.js').read
    compiled.must_match %(alert("Hello, World!");)
  end

  it 'raises an error in case of missing source' do
    sources   = @config.asset(:javascript).sources.map(&:to_s).join(', ')
    exception = -> { MissingAssetSourceView.new.render }.must_raise(Lotus::Assets::MissingAsset)

    exception.message.must_equal("Missing asset: `missing.js' (sources: #{ sources })")
  end

  it 'raises an error in case of unknown compiler engine' do
    exception = -> { UnknownAssetEngineView.new.render }.must_raise(Lotus::Assets::UnknownAssetEngine)
    exception.message.must_equal("No asset engine registered for `ouch.unknown'")
  end
end
