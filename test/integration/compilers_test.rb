require 'test_helper'

describe 'Compilers' do
  before do
    root = __dir__ + '/../fixtures'
    tmp  = Pathname.new(__dir__ + '/../../tmp')
    tmp.rmtree

    Lotus::Assets.configure do
      destination tmp.join('public')

      define :javascript do
        load_paths << [
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
end
