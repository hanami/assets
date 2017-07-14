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

    it 'renders <script> tag with a defer attribute' do
      actual = DefaultView.new.javascript('feature-a', defer: true)
      actual.must_equal %(<script defer="defer" src="/assets/feature-a.js" type="text/javascript"></script>)
    end

    it 'renders <script> tag with an integrity attribute' do
      actual = DefaultView.new.javascript('feature-a', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC')
      actual.must_equal %(<script integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" src="/assets/feature-a.js" type="text/javascript" crossorigin="anonymous"></script>)
    end

    it 'renders <script> tag with a crossorigin attribute' do
      actual = DefaultView.new.javascript('feature-a', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC', crossorigin: 'use-credentials')
      actual.must_equal %(<script integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials" src="/assets/feature-a.js" type="text/javascript"></script>)
    end

    describe 'async option' do
      it 'renders <script> tag with an async=true if async option is true' do
        actual = DefaultView.new.javascript('feature-a', async: true)
        actual.must_equal %(<script async="async" src="/assets/feature-a.js" type="text/javascript"></script>)
      end

      it 'renders <script> tag without an async=true if async option is false' do
        actual = DefaultView.new.javascript('feature-a', async: false)
        actual.must_equal %(<script src="/assets/feature-a.js" type="text/javascript"></script>)
      end
    end

    describe 'subresource_integrity mode' do
      before do
        activate_subresource_integrity_mode!
      end

      it 'includes subresource_integrity and crossorigin attributes' do
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
        actual.must_equal %(<script src="#{cdn_url}/assets/feature-a.js" type="text/javascript"></script>)
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
      actual.must_equal %(<link integrity=\"sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC\" href=\"/assets/main.css\" type=\"text/css\" rel=\"stylesheet\" crossorigin=\"anonymous\">)
    end

    it 'renders <link> tag with a crossorigin attribute' do
      actual = DefaultView.new.stylesheet('main', integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC', crossorigin: 'use-credentials')
      actual.must_equal %(<link integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="use-credentials" href="/assets/main.css" type="text/css" rel="stylesheet">)
    end

    describe 'subresource_integrity mode' do
      before do
        activate_subresource_integrity_mode!
      end

      it 'includes subresource_integrity and crossorigin attributes' do
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
        actual.must_equal %(<link href="#{cdn_url}/assets/main.css" type="text/css" rel="stylesheet">)
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
        actual.must_equal %(<img src="#{cdn_url}/assets/application.jpg" alt="Application">)
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
        actual.must_equal %(<link href="#{cdn_url}/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">)
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
        'Your browser does not support the video tag'
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
        text 'Your browser does not support the video tag'
        source src: view.asset_path('movie.mp4'), type: 'video/mp4'
        source src: view.asset_path('movie.ogg'), type: 'video/ogg'
      end.to_s

      actual.must_equal %(<video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>)
    end

    it 'raises an exception when no arguments' do
      exception = -> { view.video }.must_raise ArgumentError
      exception.message.must_equal 'You should provide a source via `src` option or with a `source` HTML tag'
    end

    it 'raises an exception when no src and no block' do
      exception = -> { view.video(content: true) }.must_raise ArgumentError
      exception.message.must_equal 'You should provide a source via `src` option or with a `source` HTML tag'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = view.video('movie.mp4').to_s
        actual.must_equal %(<video src="#{cdn_url}/assets/movie.mp4"></video>)
      end
    end
  end

  describe '#audio' do
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
        'Your browser does not support the audio tag'
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
        text 'Your browser does not support the audio tag'
        source src: view.asset_path('song.ogg'), type: 'audio/ogg'
        source src: view.asset_path('song.wav'), type: 'audio/wav'
      end.to_s

      actual.must_equal %(<audio>\nYour browser does not support the audio tag\n<source src="/assets/song.ogg" type="audio/ogg">\n<source src="/assets/song.wav" type="audio/wav">\n</audio>)
    end

    it 'raises an exception when no arguments' do
      exception = -> { view.audio }.must_raise ArgumentError
      exception.message.must_equal 'You should provide a source via `src` option or with a `source` HTML tag'
    end

    it 'raises an exception when no src and no block' do
      exception = -> { view.audio(controls: true) }.must_raise ArgumentError
      exception.message.must_equal 'You should provide a source via `src` option or with a `source` HTML tag'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url for src attribute' do
        actual = view.audio('song.ogg').to_s
        actual.must_equal %(<audio src="#{cdn_url}/assets/song.ogg"></audio>)
      end
    end
  end

  describe '#asset_path' do
    it 'returns relative URL for given asset name' do
      result = view.asset_path('application.js')
      result.must_equal '/assets/application.js'
    end

    it 'returns absolute URL if the argument is an absolute URL' do
      result = view.asset_path('http://assets.hanamirb.org/assets/application.css')
      result.must_equal 'http://assets.hanamirb.org/assets/application.css'
    end

    it 'adds source to HTTP/2 PUSH PROMISE list' do
      view.asset_path('dashboard.js')
      Thread.current[:__hanami_assets].must_include '/assets/dashboard.js'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'returns absolute url' do
        result = view.asset_path('application.js')
        result.must_equal 'https://bookshelf.cdn-example.com/assets/application.js'
      end
    end
  end

  describe '#asset_url' do
    before do
      view.class.assets_configuration.load!
    end

    it 'returns absolute URL for given asset name' do
      result = view.asset_url('application.js')
      result.must_equal('http://localhost:2300/assets/application.js')
    end

    it 'returns absolute URL if the argument is an absolute URL' do
      result = view.asset_url('http://assets.hanamirb.org/assets/application.css')
      result.must_equal 'http://assets.hanamirb.org/assets/application.css'
    end

    it 'adds source to HTTP/2 PUSH PROMISE list' do
      view.asset_url('metrics.js')
      Thread.current[:__hanami_assets].must_include 'http://localhost:2300/assets/metrics.js'
    end

    describe 'cdn mode' do
      before do
        activate_cdn_mode!
      end

      it 'still returns absolute url' do
        result = view.asset_url('application.js')
        result.must_equal 'https://bookshelf.cdn-example.com/assets/application.js'
      end
    end
  end

  describe '#ujs' do
    it 'returns an instance of SafeString' do
      UJSView.new.ujs.must_equal(
<<~HEREDOC
document.addEventListener('click', function (event) {
  var message, element;

  element = event.target;

  if (matches.call(element, 'a[data-confirm], button[data-confirm], input[data-confirm]')) {
    message = element.getAttribute('data-confirm');
    if (!confirm(message)) {
      event.stopPropagation();
      event.stopImmediatePropagation();
      event.preventDefault();
      return false;
    }

    return;
  }
}, false);
var CSRF = {
  token: function () {
    var token = document.querySelector('meta[name="csrf-token"]');
    return token && token.getAttribute('content');
  },
  param: function () {
    var param = document.querySelector('meta[name="csrf-param"]');
    return param && param.getAttribute('content');
  }
};

var sameOrigin = function (url) {
  var a = document.createElement('a'), origin;
  a.href = url;
  origin = a.href.split('/', 3).join('/');

  return window.location.href.indexOf(origin) === 0;
};

window.CSRF = CSRF;

document.addEventListener('ajax:before', function (e) {
  var token = CSRF.token(), xhr = e.detail;
  if (token)
    xhr.setRequestHeader('X-CSRF-Token', token);
});

document.addEventListener('submit', function (e) {
  var token = CSRF.token(),
      param = CSRF.param(),
      form  = e.target;

  if (matches.call(form, 'form')) {
    if (matches.call(form, 'form[data-remote]'))
      return true;
    if (!form.method || form.method.toUpperCase() == 'GET')
      return true;
    if (!sameOrigin(form.action))
      return true;

    if (param && token && !form.querySelector('input[name='+param+']')) {
      var input = document.createElement('input');
      input.setAttribute('type', 'hidden');
      input.setAttribute('name', param);
      input.setAttribute('value', token);

      form.appendChild(input);
    }

    return true;
  }
});
document.addEventListener('click', function (event) {
  var message, element;

  // do not disable on right click. Work on left and middle click
  if (event.which == 3) {
    return;
  }

  element = event.target;

  // do not disable if the element is a submit button and its form has invalid input elements.
  // since failed validations prevent the form from being submitted, we would lock the form permanently
  // by disabling the submit button even though the form was never submitted

  if(element.getAttribute("type") === "submit" && element.form.querySelector(":invalid") !== null) {
    return;
  }

  if (matches.call(element, 'a[data-disable-with], button[data-disable-with], input[data-disable-with]')) {
    message = element.getAttribute('data-disable-with');
    if(!!element.value){
      element.value = message;
    }else{
      element.innerHTML = message;
    }
    // timeout is needed because Safari stops the submit if the button is immediately disabled
    setTimeout(function(){
      element.setAttribute('disabled', 'disabled');
    }, 0);
  }
}, false);
document.addEventListener('submit', function(event) {

  var form = event.target;

  if (matches.call(form, 'form[data-remote]')) {
    var url = form.action;
    var method = (form.method || form.getAttribute('data-method') || 'POST').toUpperCase();
    var data = new FormData(form);

    if (CSRF.param() && CSRF.token()) {
      data[CSRF.param()] = CSRF.token();
    }

    if (LiteAjax.ajax({ url: url, method: method, data: data, target: form })){
      event.preventDefault();
    } else {
      return true;
    }
  }
});
var LiteAjax = (function () {
  var LiteAjax = {};

  LiteAjax.options = {
    method: 'GET',
    url: window.location.href
  };

  LiteAjax.ajax = function (url, options) {
    if (typeof url == 'object') {
      options = url;
      url = undefined;
    }

    options = options || {};

    if(!options.accepts) {
      options.accepts = 'text/javascript, application/javascript, ' +
                        'application/ecmascript, application/x-ecmascript';
    }

    url = url || options.url || location.href || '';
    var data = options.data;
    var target = options.target || document;
    var xhr = new XMLHttpRequest();

    xhr.addEventListener('load', function () {
      var responseType = xhr.getResponseHeader('content-type');
      if(responseType === 'text/javascript; charset=utf-8') {
        eval(xhr.response);
      }

      var event = new CustomEvent('ajax:complete', {detail: xhr, bubbles: true});
      target.dispatchEvent(event);
    });

    if (typeof options.success == 'function')
      xhr.addEventListener('load', function (event) {
        if (xhr.status >= 200 && xhr.status < 300)
          options.success(xhr);
      });

    if (typeof options.error == 'function') {
      xhr.addEventListener('load', function (event) {
        if (xhr.status < 200 || xhr.status >= 300)
          options.error(xhr);
      });
      xhr.addEventListener('error', function (event) {
        options.error(xhr);
      });
    }

    xhr.open(options.method || 'GET', url);
    xhr.setRequestHeader('X-Requested-With', 'XmlHttpRequest');
    xhr.setRequestHeader('Accept', '*/*;q=0.5, ' + options.accepts);

    if(options.json) {
      xhr.setRequestHeader('Content-type', 'application/json');
      data = JSON.stringify(data);
    }

    var beforeSend = new CustomEvent('ajax:before', {detail: xhr, bubbles: true});
    target.dispatchEvent(beforeSend);
    xhr.send(data);

    return xhr;
  };

  return LiteAjax;
})();
document.addEventListener('click', function(event) {
  var element, url, method, data, handler;

  // Only left click allowed. Firefox triggers click event on right click/contextmenu.
  if (event.button !== 0) {
    return;
  }

  element = event.target;

  if (matches.call(element, 'a[data-method]')) {
    url = element.getAttribute('href');
    method = element.getAttribute('data-method').toUpperCase();
    data = {};

    if (CSRF.param() && CSRF.token()) {
      data[CSRF.param()] = CSRF.token();
    }

    if (matches.call(element, 'a[data-remote]')) {
      handler = xhr;
    } else {
      handler = submit;
    }

    if (handler({ url: url, method: method, data: data, target: element })) {
      event.preventDefault();
    } else {
      return true;
    }
  }

  function submit(options) {
    var form, input, param;

    if (options.method == 'GET') {
      return false;
    }

    form = document.createElement('form');
    form.method = 'POST';
    form.action = options.url;
    form.style.display = 'none';

    for (param in options.data) {
      if (Object.prototype.hasOwnProperty.call(options.data, param)) {
        input = document.createElement('input');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name', param);
        input.setAttribute('value', options.data[param]);
        form.appendChild(input);
      }
    }

    if (options.method != 'POST') {
      input = document.createElement('input');
      input.setAttribute('type', 'hidden');
      input.setAttribute('name', '_method');
      input.setAttribute('value', options.method);
      form.appendChild(input);
    }

    document.body.appendChild(form);
    form.submit();
    return true;
  }

  function xhr(options) {
    LiteAjax.ajax(options);
    return true;
  }
}, false);
var matches = (function(doc) {
  return doc.matchesSelector ||
    doc.webkitMatchesSelector ||
    doc.mozMatchesSelector ||
    doc.oMatchesSelector ||
    doc.msMatchesSelector;
})(document.documentElement);

var CustomEvent = function (event, params) {
  params = params || {bubbles: false, cancelable: false, detail: undefined};
  var evt = document.createEvent('CustomEvent');
  evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
  return evt;
};

CustomEvent.prototype = window.CustomEvent.prototype;

window.CustomEvent = CustomEvent;
HEREDOC
      )
    end
  end

  private

  def activate_subresource_integrity_mode! # rubocop:disable Metrics/MethodLength
    view.class.assets_configuration.subresource_integrity true
    view.class.assets_configuration.load!

    manifest = Hanami::Assets::Config::Manifest.new({
                                                      '/assets/feature-a.js' => {
                                                        'sri' => [
                                                          'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
                                                        ]
                                                      },
                                                      '/assets/main.css' => {
                                                        'sri' => [
                                                          'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
                                                        ]
                                                      }
                                                    }, [])
    view.class.assets_configuration.instance_variable_set(:@public_manifest, manifest)
  end

  def activate_cdn_mode! # rubocop:disable Metrics/AbcSize
    view.class.assets_configuration.scheme 'https'
    view.class.assets_configuration.host   'bookshelf.cdn-example.com'
    view.class.assets_configuration.port   '443'
    view.class.assets_configuration.cdn    true

    view.class.assets_configuration.load!
  end
end
