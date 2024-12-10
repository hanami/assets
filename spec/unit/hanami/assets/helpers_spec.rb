# frozen_string_literal: true

RSpec.describe Hanami::Assets::Helpers do
  let(:view)    { ImageHelperView.new({}, **{}) }
  let(:cdn_url) { "https://bookshelf.cdn-example.com" }

  before do
    view.class.assets_configuration.load!
    Thread.current[:__hanami_assets] = nil
  end

  after do
    view.class.assets_configuration.reset!
  end

  describe "#javascript" do
    it "returns an instance of SafeString" do
      actual = DefaultView.new.javascript("feature-a")
      expect(actual).to be_instance_of(::Hanami::CygUtils::Escape::SafeString)
    end

    it "renders <script> tag" do
      actual = DefaultView.new.javascript("feature-a")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
    end

    it "renders <script> tag without appending ext after query string" do
      actual = DefaultView.new.javascript("feature-x?callback=init")
      expect(actual).to eq(%(<script src="/assets/feature-x?callback=init" type="text/javascript"></script>))
    end

    it "renders <script> tag with a defer attribute" do
      actual = DefaultView.new.javascript("feature-a", defer: true)
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" defer="defer"></script>))
    end

    it "renders <script> tag with an integrity attribute" do
      actual = DefaultView.new.javascript("feature-a", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>))
    end

    it "renders <script> tag with a crossorigin attribute" do
      actual = DefaultView.new.javascript("feature-a", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC", crossorigin: "use-credentials")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials"></script>))
    end

    it "ignores src passed as an option" do
      actual = DefaultView.new.javascript("feature-a", src: "wrong")
      expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
    end

    describe "async option" do
      it "renders <script> tag with an async=true if async option is true" do
        actual = DefaultView.new.javascript("feature-a", async: true)
        expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" async="async"></script>))
      end

      it "renders <script> tag without an async=true if async option is false" do
        actual = DefaultView.new.javascript("feature-a", async: false)
        expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript"></script>))
      end
    end

    describe "subresource_integrity mode" do
      before do
        activate_subresource_integrity_mode!
      end

      it "includes subresource_integrity and crossorigin attributes" do
        actual = DefaultView.new.javascript("feature-a")
        expect(actual).to eq(%(<script src="/assets/feature-a.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>))
      end
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for src attribute" do
        actual = DefaultView.new.javascript("feature-a")
        expect(actual).to eq(%(<script src="#{cdn_url}/assets/feature-a.js" type="text/javascript"></script>))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "includes asset in push promise assets" do
        DefaultView.new.javascript("feature-a")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/feature-a.js")).to eq(as: :script, crossorigin: false)
      end

      it "includes crossorigin asset in push promise assets" do
        DefaultView.new.javascript("https://assets.hanamirb.org/assets/framework.js")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("https://assets.hanamirb.org/assets/framework.js")).to eq(as: :script, crossorigin: true)
      end

      it "allows asset exclusion from push promise assets" do
        actual = DefaultView.new.javascript("feature-b", push: false)
        expect(actual).to eq(%(<script src="/assets/feature-b.js" type="text/javascript"></script>))
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "includes multiple assets in push promise assets" do
        DefaultView.new.javascript("feature-c", "feature-d")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/feature-c.js")).to eq(as: :script, crossorigin: false)
        expect(assets.fetch("/assets/feature-d.js")).to eq(as: :script, crossorigin: false)
      end

      it "allows the exclusion of multiple assets from push promise assets" do
        DefaultView.new.javascript("feature-e", "feature-f", push: false)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end
    end
  end

  describe "#stylesheet" do
    it "returns an instance of SafeString" do
      actual = DefaultView.new.stylesheet("main")
      expect(actual).to be_instance_of(::Hanami::CygUtils::Escape::SafeString)
    end

    it "renders <link> tag" do
      actual = DefaultView.new.stylesheet("main")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet">))
    end

    it "renders <link> tag without appending ext after query string" do
      actual = DefaultView.new.stylesheet("fonts?font=Helvetica")
      expect(actual).to eq(%(<link href="/assets/fonts?font=Helvetica" type="text/css" rel="stylesheet">))
    end

    it "renders <link> tag with an integrity attribute" do
      actual = DefaultView.new.stylesheet("main", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous">))
    end

    it "renders <link> tag with a crossorigin attribute" do
      actual = DefaultView.new.stylesheet("main", integrity: "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC", crossorigin: "use-credentials")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials">))
    end

    it "ignores href passed as an option" do
      actual = DefaultView.new.stylesheet("main", href: "wrong")
      expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet">))
    end

    describe "subresource_integrity mode" do
      before do
        activate_subresource_integrity_mode!
      end

      it "includes subresource_integrity and crossorigin attributes" do
        actual = DefaultView.new.stylesheet("main")
        expect(actual).to eq(%(<link href="/assets/main.css" type="text/css" rel="stylesheet" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous">))
      end
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for href attribute" do
        actual = DefaultView.new.stylesheet("main")
        expect(actual).to eq(%(<link href="#{cdn_url}/assets/main.css" type="text/css" rel="stylesheet">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "includes asset in push promise assets" do
        DefaultView.new.stylesheet("main")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/main.css")).to eq(as: :style, crossorigin: false)
      end

      it "allows asset exclusion from push promise assets" do
        actual = DefaultView.new.stylesheet("fonts", push: false)
        expect(actual).to eq(%(<link href="/assets/fonts.css" type="text/css" rel="stylesheet">))
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "includes multiple assets in push promise assets" do
        DefaultView.new.stylesheet("framework", "styles")
        assets = Thread.current[:__hanami_assets]

        expect(assets.fetch("/assets/framework.css")).to eq(as: :style, crossorigin: false)
        expect(assets.fetch("/assets/styles.css")).to eq(as: :style, crossorigin: false)
      end

      it "allows the exclusion of multiple assets from push promise assets" do
        DefaultView.new.stylesheet("framework", "styles", push: false)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end
    end
  end

  describe "image" do
    it "returns an instance of HtmlBuilder" do
      actual = view.image("application.jpg")
      expect(actual).to be_instance_of(::Hanami::Helpers::HtmlHelper::HtmlBuilder)
    end

    it "renders an <img> tag" do
      actual = view.image("application.jpg").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    it "custom alt" do
      actual = view.image("application.jpg", alt: "My Alt").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="My Alt">))
    end

    it "custom data attribute" do
      actual = view.image("application.jpg", "data-user-id" => 5).to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application" data-user-id="5">))
    end

    it "ignores src passed as an option" do
      actual = view.image("application.jpg", src: "wrong").to_s
      expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for src attribute" do
        actual = view.image("application.jpg").to_s
        expect(actual).to eq(%(<img src="#{cdn_url}/assets/application.jpg" alt="Application">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        view.image("application.jpg")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows assets inclusion in push promise assets" do
        actual = view.image("application.jpg", push: true).to_s
        expect(actual).to eq(%(<img src="/assets/application.jpg" alt="Application">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/application.jpg")).to eq(as: :image, crossorigin: false)
      end

      it "allows crossorigin assets inclusion in push promise assets" do
        actual = view.image("https://assets.hanamirb.org/assets/application.jpg", push: true).to_s
        expect(actual).to eq(%(<img src="https://assets.hanamirb.org/assets/application.jpg" alt="Application">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/application.jpg")).to eq(as: :image, crossorigin: true)
      end
    end
  end

  describe "#favicon" do
    it "returns an instance of HtmlBuilder" do
      actual = view.favicon
      expect(actual).to be_instance_of(::Hanami::Helpers::HtmlHelper::HtmlBuilder)
    end

    it "renders <link> tag" do
      actual = view.favicon.to_s
      expect(actual).to eq(%(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
    end

    it "renders with HTML attributes" do
      actual = view.favicon("favicon.png", rel: "icon", type: "image/png").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="icon" type="image/png">))
    end

    it "ignores href passed as an option" do
      actual = view.favicon("favicon.png", href: "wrong").to_s
      expect(actual).to eq(%(<link href="/assets/favicon.png" rel="shortcut icon" type="image/x-icon">))
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for href attribute" do
        actual = view.favicon.to_s
        expect(actual).to eq(%(<link href="#{cdn_url}/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        view.favicon
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows assets inclusion in push promise assets" do
        actual = view.favicon("favicon.ico", push: true).to_s
        expect(actual).to eq(%(<link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/favicon.ico")).to eq(as: :image, crossorigin: false)
      end

      it "allows crossorigin assets inclusion in push promise assets" do
        actual = view.favicon("https://assets.hanamirb.org/assets/favicon.ico", push: true).to_s
        expect(actual).to eq(%(<link href="https://assets.hanamirb.org/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/favicon.ico")).to eq(as: :image, crossorigin: true)
      end
    end
  end

  describe "#video" do
    it "returns an instance of HtmlBuilder" do
      actual = view.video("movie.mp4")
      expect(actual).to be_instance_of(::Hanami::Helpers::HtmlHelper::HtmlBuilder)
    end

    it "renders <video> tag" do
      actual = view.video("movie.mp4").to_s
      expect(actual).to eq(%(<video src="/assets/movie.mp4"></video>))
    end

    it "renders with html attributes" do
      actual = view.video("movie.mp4", autoplay: true, controls: true).to_s
      expect(actual).to eq(%(<video autoplay="autoplay" controls="controls" src="/assets/movie.mp4"></video>))
    end

    it "renders with fallback content" do
      actual = view.video("movie.mp4") do
        "Your browser does not support the video tag"
      end.to_s

      expect(actual).to eq(%(<video src="/assets/movie.mp4">\nYour browser does not support the video tag\n</video>))
    end

    it "renders with tracks" do
      actual = view.video("movie.mp4") do
        track kind: "captions", src: view.asset_path("movie.en.vtt"), srclang: "en", label: "English"
      end.to_s

      expect(actual).to eq(%(<video src="/assets/movie.mp4">\n<track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">\n</video>))
    end

    it "renders with sources" do
      actual = view.video do
        text "Your browser does not support the video tag"
        source src: view.asset_path("movie.mp4"), type: "video/mp4"
        source src: view.asset_path("movie.ogg"), type: "video/ogg"
      end.to_s

      expect(actual).to eq(%(<video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>))
    end

    it "raises an exception when no arguments" do
      expect do
        view.video
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    it "raises an exception when no src and no block" do
      expect do
        view.video(content: true)
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for src attribute" do
        actual = view.video("movie.mp4").to_s
        expect(actual).to eq(%(<video src="#{cdn_url}/assets/movie.mp4"></video>))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        view.video("movie.mp4")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows asset inclusion in push promise assets" do
        actual = view.video("movie.mp4", push: true).to_s
        expect(actual).to eq(%(<video src="/assets/movie.mp4"></video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end

      it "allows crossorigin asset inclusion in push promise assets" do
        actual = view.video("https://assets.hanamirb.org/assets/movie.mp4", push: true).to_s
        expect(actual).to eq(%(<video src="https://assets.hanamirb.org/assets/movie.mp4"></video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirb.org/assets/movie.mp4")).to eq(as: :video, crossorigin: true)
      end

      it "allows asset inclusion in push promise assets when using block syntax" do
        actual = view.video("movie.mp4", push: true) do
          "Your browser does not support the video tag"
        end.to_s

        expect(actual).to eq(%(<video src="/assets/movie.mp4">\nYour browser does not support the video tag\n</video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end

      it "allows asset inclusion in push promise assets when using block syntax and source tags" do
        actual = view.video do
          text "Your browser does not support the video tag"
          source src: view.asset_path("movie.mp4", push: :video), type: "video/mp4"
          source src: view.asset_path("movie.ogg"), type: "video/ogg"
        end.to_s

        expect(actual).to eq(%(<video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/movie.mp4")).to eq(as: :video, crossorigin: false)
      end
    end
  end

  describe "#audio" do
    it "returns an instance of HtmlBuilder" do
      actual = view.audio("song.ogg")
      expect(actual).to be_instance_of(::Hanami::Helpers::HtmlHelper::HtmlBuilder)
    end

    it "renders <audio> tag" do
      actual = view.audio("song.ogg").to_s
      expect(actual).to eq(%(<audio src="/assets/song.ogg"></audio>))
    end

    it "renders with html attributes" do
      actual = view.audio("song.ogg", autoplay: true, controls: true).to_s
      expect(actual).to eq(%(<audio autoplay="autoplay" controls="controls" src="/assets/song.ogg"></audio>))
    end

    it "renders with fallback content" do
      actual = view.audio("song.ogg") do
        "Your browser does not support the audio tag"
      end.to_s

      expect(actual).to eq(%(<audio src="/assets/song.ogg">\nYour browser does not support the audio tag\n</audio>))
    end

    it "renders with tracks" do
      actual = view.audio("song.ogg") do
        track kind: "captions", src: view.asset_path("song.pt-BR.vtt"), srclang: "pt-BR", label: "Portuguese"
      end.to_s

      expect(actual).to eq(%(<audio src="/assets/song.ogg">\n<track kind="captions" src="/assets/song.pt-BR.vtt" srclang="pt-BR" label="Portuguese">\n</audio>))
    end

    it "renders with sources" do
      actual = view.audio do
        text "Your browser does not support the audio tag"
        source src: view.asset_path("song.ogg"), type: "audio/ogg"
        source src: view.asset_path("song.wav"), type: "audio/wav"
      end.to_s

      expect(actual).to eq(%(<audio>\nYour browser does not support the audio tag\n<source src="/assets/song.ogg" type="audio/ogg">\n<source src="/assets/song.wav" type="audio/wav">\n</audio>))
    end

    it "raises an exception when no arguments" do
      expect do
        view.audio
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    it "raises an exception when no src and no block" do
      expect do
        view.audio(controls: true)
      end.to raise_error(ArgumentError,
                         "You should provide a source via `src` option or with a `source` HTML tag")
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url for src attribute" do
        actual = view.audio("song.ogg").to_s
        expect(actual).to eq(%(<audio src="#{cdn_url}/assets/song.ogg"></audio>))
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't include asset in push promise assets" do
        view.audio("song.ogg")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "allows asset inclusion in push promise assets" do
        actual = view.audio("song.ogg", push: true).to_s
        expect(actual).to eq(%(<audio src="/assets/song.ogg"></audio>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/song.ogg")).to eq(as: :audio, crossorigin: false)
      end

      it "allows crossorigin asset inclusion in push promise assets" do
        actual = view.audio("https://assets.hanamirbg.org/assets/song.ogg", push: true).to_s
        expect(actual).to eq(%(<audio src="https://assets.hanamirbg.org/assets/song.ogg"></audio>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("https://assets.hanamirbg.org/assets/song.ogg")).to eq(as: :audio, crossorigin: true)
      end

      it "allows asset inclusion in push promise assets when using block syntax" do
        actual = view.audio("song.ogg", push: true) do
          "Your browser does not support the audio tag"
        end.to_s

        expect(actual).to eq(%(<audio src="/assets/song.ogg">\nYour browser does not support the audio tag\n</audio>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/song.ogg")).to eq(as: :audio, crossorigin: false)
      end

      it "allows asset inclusion in push promise assets when using block syntax and source tags" do
        actual = view.audio do
          text "Your browser does not support the audio tag"
          source src: view.asset_path("song.ogg", push: :audio), type: "audio/ogg"
          source src: view.asset_path("song.wav"), type: "audio/wav"
        end.to_s

        expect(actual).to eq(%(<audio>\nYour browser does not support the audio tag\n<source src="/assets/song.ogg" type="audio/ogg">\n<source src="/assets/song.wav" type="audio/wav">\n</audio>))

        assets = Thread.current[:__hanami_assets]
        expect(assets.fetch("/assets/song.ogg")).to eq(as: :audio, crossorigin: false)
      end
    end
  end

  describe "#asset_path" do
    it "returns relative URL for given asset name" do
      result = view.asset_path("application.js")
      expect(result).to eq("/assets/application.js")
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_path("http://assets.hanamirb.org/assets/application.css")
      expect(result).to eq("http://assets.hanamirb.org/assets/application.css")
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "returns absolute url" do
        result = view.asset_path("application.js")
        expect(result).to eq("https://bookshelf.cdn-example.com/assets/application.js")
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't add into assets list by default" do
        view.asset_path("dashboard.js")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "adds asset into assets list" do
        view.asset_path("dashboard.js", push: true)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("/assets/dashboard.js")).to eq(as: nil, crossorigin: false)
      end

      it "allows to specify asset type" do
        view.asset_path("video.mp4", push: :video)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("/assets/video.mp4")).to eq(as: :video, crossorigin: false)
      end

      it "allows to link crossorigin asset" do
        view.asset_path("https://assets.hanamirb.org/assets/video.mp4", push: :video)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("https://assets.hanamirb.org/assets/video.mp4")).to eq(as: :video, crossorigin: true)
      end
    end
  end

  describe "#asset_url" do
    before do
      view.class.assets_configuration.load!
    end

    it "returns absolute URL for given asset name" do
      result = view.asset_url("application.js")
      expect(result).to eq("http://localhost:2300/assets/application.js")
    end

    it "returns absolute URL if the argument is an absolute URL" do
      result = view.asset_url("http://assets.hanamirb.org/assets/application.css")
      expect(result).to eq("http://assets.hanamirb.org/assets/application.css")
    end

    describe "cdn mode" do
      before do
        activate_cdn_mode!
      end

      it "still returns absolute url" do
        result = view.asset_url("application.js")
        expect(result).to eq("https://bookshelf.cdn-example.com/assets/application.js")
      end
    end

    context "HTTP/2 PUSH PROMISE" do
      it "doesn't add into assets list by default" do
        view.asset_url("metrics.js")
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be(nil)
      end

      it "adds asset into assets list" do
        view.asset_url("metrics.js", push: true)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("http://localhost:2300/assets/metrics.js")).to eq(as: nil, crossorigin: false)
      end

      it "allows to specify asset type" do
        view.asset_url("metrics.js", push: :script)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("http://localhost:2300/assets/metrics.js")).to eq(as: :script, crossorigin: false)
      end

      it "allows to link crossorigin asset" do
        view.asset_url("https://assets.hanamirb.org/assets/metrics.js", push: :script)
        assets = Thread.current[:__hanami_assets]

        expect(assets).to be_kind_of(Hash)
        expect(assets.fetch("https://assets.hanamirb.org/assets/metrics.js")).to eq(as: :script, crossorigin: true)
      end
    end
  end

  private

  def activate_subresource_integrity_mode!
    view.class.assets_configuration.subresource_integrity true
    view.class.assets_configuration.load!

    manifest = Hanami::Assets::Config::Manifest.new({
                                                      "/assets/feature-a.js" => {
                                                        "sri" => [
                                                          "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
                                                        ]
                                                      },
                                                      "/assets/main.css" => {
                                                        "sri" => [
                                                          "sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
                                                        ]
                                                      }
                                                    }, [])
    view.class.assets_configuration.instance_variable_set(:@public_manifest, manifest)
  end

  def activate_cdn_mode!
    view.class.assets_configuration.scheme "https"
    view.class.assets_configuration.host   "bookshelf.cdn-example.com"
    view.class.assets_configuration.port   "443"
    view.class.assets_configuration.cdn    true

    view.class.assets_configuration.load!
  end
end
