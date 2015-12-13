require 'test_helper'

describe Lotus::Assets::Helpers do

  def safe_string_class
    ::Lotus::Utils::Escape::SafeString
  end

  let(:view) { ImageHelperView.new({}, {}) }

  describe '#javascript' do
    before do
      @javascript = DefaultView.new.javascript('feature-a')
    end

    it 'returns an instance of SafeString' do
      @javascript.must_be_instance_of safe_string_class
    end
  end

  describe '#stylesheet' do
    before do
      @stylesheet = DefaultView.new.stylesheet('main')
    end

    it 'returns an instance of SafeString' do
      @stylesheet.must_be_instance_of safe_string_class
    end
  end

  describe 'image' do
    it 'render an img tag' do
      view.image('application.jpg').to_s.must_equal %(<img src=\"/assets/application.jpg\" alt=\"Application\">)
    end

    it 'custom alt' do
      view.image('application.jpg', alt: 'My Alt').to_s.must_equal %(<img alt=\"My Alt\" src=\"/assets/application.jpg\">)
    end

    it 'custom data attribute' do
      view.image('application.jpg', 'data-user-id' => 5).to_s.must_equal %(<img data-user-id=\"5\" src=\"/assets/application.jpg\" alt=\"Application\">)
    end
  end

  describe '#favicon' do
    it 'renders' do
      view.favicon.to_s.must_equal %(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">)
    end

    it 'renders with HTML attributes' do
      view.favicon('favicon.png', rel: 'icon', type: 'image/png').to_s.must_equal %(<link rel="icon" type="image/png" href="/assets/favicon.png">)
    end
  end

  describe '#video' do
    it 'renders' do
      tag = view.video('movie.mp4')
      tag.to_s.must_equal %(<video src="/assets/movie.mp4"></video>)
    end

    it 'renders with html attributes' do
      tag = view.video('movie.mp4', autoplay: true, controls: true)
      tag.to_s.must_equal %(<video autoplay="autoplay" controls="controls" src="/assets/movie.mp4"></video>)
    end

    it 'renders with fallback content' do
      tag = view.video('movie.mp4') do
        "Your browser does not support the video tag"
      end
      tag.to_s.must_equal %(<video src="/assets/movie.mp4">\nYour browser does not support the video tag\n</video>)
    end

    it 'renders with tracks' do
      tag = view.video('movie.mp4') do
        track kind: 'captions', src: view.asset_path('movie.en.vtt'), srclang: 'en', label: 'English'
      end
      tag.to_s.must_equal %(<video src="/assets/movie.mp4">\n<track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">\n</video>)
    end

    it 'renders with sources' do
      tag = view.video do
        text "Your browser does not support the video tag"
        source src: view.asset_path('movie.mp4'), type: 'video/mp4'
        source src: view.asset_path('movie.ogg'), type: 'video/ogg'
      end
      tag.to_s.must_equal %(<video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>)
    end

    it 'raises an exception when no arguments' do
      -> {view.video()}.must_raise ArgumentError
    end

    it 'raises an exception when no src and no block' do
      -> {view.video(content: true)}.must_raise ArgumentError
    end
  end

  describe "#asset_path" do
    it "returns relative URL for given asset name" do
      result = view.asset_path('application.js')
      result.must_equal '/assets/application.js'
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_path('http://assets.lotusrb.org/assets/application.css')
      result.must_equal 'http://assets.lotusrb.org/assets/application.css'
    end

    it "adds source to HTTP/2 PUSH PROMISE list" do
      view.asset_path('dashboard.js')
      Thread.current[:__lotus_assets].must_include '/assets/dashboard.js'
    end
  end

  describe "#asset_url" do
    before do
      view.class.assets_configuration.load!
    end

    after do
      view.class.assets_configuration.reset!
    end

    it "returns absolute URL for given asset name" do
      result = view.asset_url('application.js')
      result.must_equal('http://localhost:2300/assets/application.js')
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_url('http://assets.lotusrb.org/assets/application.css')
      result.must_equal 'http://assets.lotusrb.org/assets/application.css'
    end

    it "adds source to HTTP/2 PUSH PROMISE list" do
      view.asset_url('metrics.js')
      Thread.current[:__lotus_assets].must_include 'http://localhost:2300/assets/metrics.js'
    end
  end
end

