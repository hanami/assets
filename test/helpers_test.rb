require 'test_helper'

describe Hanami::Assets::Helpers do
  let(:view)    { ImageHelperView.new({}, {}) }
  let(:cdn_url) { 'https://bookshelf.cdn-example.com' }

  after do
    view.class.assets_configuration.reset!
  end

  describe '#javascript' do
    it 'returns an instance of SafeString' do
      actual = DefaultView.new.javascript('feature-a')
      actual.must_be_instance_of ::Hanami::Utils::Escape::SafeString
    end

    it 'renders <script> tag' do
      actual = DefaultView.new.javascript('feature-a')
      actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
    end

    it 'renders <script> tag with an async attribute' do
      actual = DefaultView.new.javascript('feature-a', async: true)
      actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript" async="async"></script>)
    end

    it 'renders <script> tag with a defer attribute' do
      actual = DefaultView.new.javascript('feature-a', defer: true)
      actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript" defer="defer"></script>)
    end

    it 'renders <script> tag with an integrity attribute' do
      actual = DefaultView.new.javascript('feature-a', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC')
      actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>)
    end

    it 'renders <script> tag with a crossorigin attribute' do
      actual = DefaultView.new.javascript('feature-a', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC', crossorigin: 'use-credentials')
      actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials"></script>)
    end

    describe 'sri mode' do
      before do
        activate_sri_mode!
      end

      it 'includes sri and crossorigin attributes' do
        actual = DefaultView.new.javascript('feature-a')
        actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>)
      end
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = DefaultView.new.javascript('feature-a')
        actual.must_equal %(<script src="#{ cdn_url }/assets/feature-a.js" type="text/javascript"></script>)
      end
    end
  end

  describe '#stylesheet' do
    it 'returns an instance of SafeString' do
      actual = DefaultView.new.stylesheet('main')
      actual.must_be_instance_of ::Hanami::Utils::Escape::SafeString
    end

    it 'renders <link> tag' do
      actual = DefaultView.new.stylesheet('main')
      actual.must_equal %(<link href="/assets/main.css" type="text/css" rel="stylesheet">)
    end

    it 'renders <link> tag with an integrity attribute' do
      actual = DefaultView.new.stylesheet('main', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC')
      actual.must_equal %(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous">)
    end

    it 'renders <link> tag with a crossorigin attribute' do
      actual = DefaultView.new.stylesheet('main', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC', crossorigin: 'use-credentials')
      actual.must_equal %(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials">)
    end

    describe 'sri mode' do
      before do
        activate_sri_mode!
      end

      it 'includes sri and crossorigin attributes' do
        actual = DefaultView.new.stylesheet('main')
        actual.must_equal %(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous">)
      end
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for href attribute' do
        actual = DefaultView.new.stylesheet('main')
        actual.must_equal %(<link href="#{ cdn_url }/assets/main.css" type="text/css" rel="stylesheet">)
      end
    end
  end

  describe 'image' do
    it 'returns an instance of HtmlBuilder' do
      actual = view.image('application.jpg')
      actual.must_be_instance_of ::Hanami::Helpers::HtmlHelper::HtmlBuilder
    end

    it 'renders an <img> tag' do
      actual = view.image('application.jpg').to_s
      actual.must_equal %(<img src="/assets/application.jpg" alt="Application">)
    end

    it 'custom alt' do
      actual = view.image('application.jpg', alt: 'My Alt').to_s
      actual.must_equal %(<img alt="My Alt" src="/assets/application.jpg">)
    end

    it 'custom data attribute' do
      actual = view.image('application.jpg', 'data-user-id' => 5).to_s
      actual.must_equal %(<img data-user-id="5" src="/assets/application.jpg" alt="Application">)
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = view.image('application.jpg').to_s
        actual.must_equal %(<img src="#{ cdn_url }/assets/application.jpg" alt="Application">)
      end
    end
  end

  describe '#favicon' do
    it 'returns an instance of HtmlBuilder' do
      actual = view.favicon
      actual.must_be_instance_of ::Hanami::Helpers::HtmlHelper::HtmlBuilder
    end

    it 'renders <link> tag' do
      actual = view.favicon.to_s
      actual.must_equal %(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">)
    end

    it 'renders with HTML attributes' do
      actual = view.favicon('favicon.png', rel: 'icon', type: 'image/png').to_s
      actual.must_equal %(<link rel="icon" type="image/png" href="/assets/favicon.png">)
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for href attribute' do
        actual = view.favicon.to_s
        actual.must_equal %(<link href="#{ cdn_url }/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">)
      end
    end
  end

  describe '#video' do
    it 'returns an instance of HtmlBuilder' do
      actual = view.video('movie.mp4')
      actual.must_be_instance_of ::Hanami::Helpers::HtmlHelper::HtmlBuilder
    end

    it 'renders <video> tag' do
      actual = view.video('movie.mp4').to_s
      actual.must_equal %(<video src="/assets/movie.mp4"></video>)
    end

    it 'renders with html attributes' do
      actual = view.video('movie.mp4', autoplay: true, controls: true).to_s
      actual.must_equal %(<video autoplay="autoplay" controls="controls" src="/assets/movie.mp4"></video>)
    end

    it 'renders with fallback content' do
      actual = view.video('movie.mp4') do
        "Your browser does not support the video tag"
      end.to_s

      actual.must_equal %(<video src="/assets/movie.mp4">\nYour browser does not support the video tag\n</video>)
    end

    it 'renders with tracks' do
      actual = view.video('movie.mp4') do
        track kind: 'captions', src: view.asset_path('movie.en.vtt'), srclang: 'en', label: 'English'
      end.to_s

      actual.must_equal %(<video src="/assets/movie.mp4">\n<track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">\n</video>)
    end

    it 'renders with sources' do
      actual = view.video do
        text "Your browser does not support the video tag"
        source src: view.asset_path('movie.mp4'), type: 'video/mp4'
        source src: view.asset_path('movie.ogg'), type: 'video/ogg'
      end.to_s

      actual.must_equal %(<video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>)
    end

    it 'raises an exception when no arguments' do
      exception = -> { view.video() }.must_raise ArgumentError
      exception.message.must_equal "You should provide a source via `src` option or with a `source` HTML tag"
    end

    it 'raises an exception when no src and no block' do
      exception = -> { view.video(content: true) }.must_raise ArgumentError
      exception.message.must_equal "You should provide a source via `src` option or with a `source` HTML tag"
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = view.video('movie.mp4').to_s
        actual.must_equal %(<video src="#{ cdn_url }/assets/movie.mp4"></video>)
      end
    end
  end


  describe "#audio" do
    it 'returns an instance of HtmlBuilder' do
      actual = view.audio('song.ogg')
      actual.must_be_instance_of ::Hanami::Helpers::HtmlHelper::HtmlBuilder
    end

    it 'renders <audio> tag' do
      actual = view.audio('song.ogg').to_s
      actual.must_equal %(<audio src="/assets/song.ogg"></audio>)
    end

    it 'renders with html attributes' do
      actual = view.audio('song.ogg', autoplay: true, controls: true).to_s
      actual.must_equal %(<audio autoplay="autoplay" controls="controls" src="/assets/song.ogg"></audio>)
    end

    it 'renders with fallback content' do
      actual = view.audio('song.ogg') do
        "Your browser does not support the audio tag"
      end.to_s

      actual.must_equal %(<audio src="/assets/song.ogg">\nYour browser does not support the audio tag\n</audio>)
    end

    it 'renders with tracks' do
      actual = view.audio('song.ogg') do
        track kind: 'captions', src: view.asset_path('song.pt-BR.vtt'), srclang: 'pt-BR', label: 'Portuguese'
      end.to_s

      actual.must_equal %(<audio src="/assets/song.ogg">\n<track kind="captions" src="/assets/song.pt-BR.vtt" srclang="pt-BR" label="Portuguese">\n</audio>)
    end

    it 'renders with sources' do
      actual = view.audio do
        text "Your browser does not support the audio tag"
        source src: view.asset_path('song.ogg'), type: 'audio/ogg'
        source src: view.asset_path('song.wav'), type: 'audio/wav'
      end.to_s

      actual.must_equal %(<audio>\nYour browser does not support the audio tag\n<source src="/assets/song.ogg" type="audio/ogg">\n<source src="/assets/song.wav" type="audio/wav">\n</audio>)
    end

    it 'raises an exception when no arguments' do
      exception = -> { view.audio() }.must_raise ArgumentError
      exception.message.must_equal "You should provide a source via `src` option or with a `source` HTML tag"
    end

    it 'raises an exception when no src and no block' do
      exception = -> { view.audio(controls: true) }.must_raise ArgumentError
      exception.message.must_equal "You should provide a source via `src` option or with a `source` HTML tag"
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = view.audio('song.ogg').to_s
        actual.must_equal %(<audio src="#{ cdn_url }/assets/song.ogg"></audio>)
      end
    end
  end

  describe "#asset_path" do
    it "returns relative URL for given asset name" do
      result = view.asset_path('application.js')
      result.must_equal '/assets/application.js'
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_path('http://assets.hanamirb.org/assets/application.css')
      result.must_equal 'http://assets.hanamirb.org/assets/application.css'
    end

    it "adds source to HTTP/2 PUSH PROMISE list" do
      view.asset_path('dashboard.js')
      Thread.current[:__hanami_assets].must_include '/assets/dashboard.js'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url' do
        result = view.asset_path('application.js')
        result.must_equal "https://bookshelf.cdn-example.com/assets/application.js"
      end
    end
  end

  describe "#asset_url" do
    before do
      view.class.assets_configuration.load!
    end

    it "returns absolute URL for given asset name" do
      result = view.asset_url('application.js')
      result.must_equal('http://localhost:2300/assets/application.js')
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_url('http://assets.hanamirb.org/assets/application.css')
      result.must_equal 'http://assets.hanamirb.org/assets/application.css'
    end

    it "adds source to HTTP/2 PUSH PROMISE list" do
      view.asset_url('metrics.js')
      Thread.current[:__hanami_assets].must_include 'http://localhost:2300/assets/metrics.js'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'still returns absolute url' do
        result = view.asset_url('application.js')
        result.must_equal "https://bookshelf.cdn-example.com/assets/application.js"
      end
    end
  end

  private

  def activate_sri_mode!
    view.class.assets_configuration.sri true
    view.class.assets_configuration.load!

    manifest = Hanami::Assets::Config::DigestManifest.new({
      '/assets/feature-a.js' => {
        'sri' => 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
      },
      '/assets/main.css' => {
        'sri' => 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
      }
    }, [])
    view.class.assets_configuration.instance_variable_set(:@digest_manifest, manifest)
  end

  def activate_cdn_mode!
    view.class.assets_configuration.scheme 'https'
    view.class.assets_configuration.host   'bookshelf.cdn-example.com'
    view.class.assets_configuration.port   '443'
    view.class.assets_configuration.cdn    true

    view.class.assets_configuration.load!
  end
end
