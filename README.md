# Hanami::Assets

Assets management for Ruby web projects

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-assets.svg)](https://badge.fury.io/rb/hanami-assets)
[![TravisCI](https://travis-ci.org/hanami/assets.svg?branch=master)](https://travis-ci.org/hanami/assets)
[![CircleCI](https://circleci.com/gh/hanami/assets/tree/master.svg?style=svg)](https://circleci.com/gh/hanami/assets/tree/master)
[![Test Coverage](https://codecov.io/gh/hanami/assets/branch/master/graph/badge.svg)](https://codecov.io/gh/hanami/assets)
[![Depfu](https://badges.depfu.com/badges/4b37347bd74042ff96477495cc16531d/overview.svg)](https://depfu.com/github/hanami/assets?project=Bundler)
[![Inline Docs](http://inch-ci.org/github/hanami/assets.svg)](http://inch-ci.org/github/hanami/assets)

## Contact

* Home page: http://hanamirb.org
* Community: http://hanamirb.org/community
* Guides: https://guides.hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-assets
* Bugs/Issues: https://github.com/hanami/assets/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Forum: https://discuss.hanamirb.org
* Chat: http://chat.hanamirb.org

## Rubies

__Hanami::Assets__ supports Ruby (MRI) 2.3+ and JRuby 9.1.5.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-assets'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install hanami-assets
```

## Usage

### Helpers

`Hanami::Assets` provides asset-specific helpers to be used in templates.
They resolve one or multiple sources into corresponding HTML tags.
Those sources can be either a name of a local asset or an absolute URL.

Given the following template:

```erb
<!doctype HTML>
<html>
  <head>
    <title>Assets example</title>
    <%= stylesheet 'reset', 'grid', 'main' %>
  </head>

  <body>
  <!-- ... -->
  <%= javascript 'https://code.jquery.com/jquery-2.1.1.min.js', 'application' %>
  <%= javascript 'modals' %>
  </body>
</html>
```

It will output this markup:

```html
<!doctype HTML>
<html>
  <head>
    <title>Assets example</title>
    <link href="/assets/reset.css" type="text/css" rel="stylesheet">
    <link href="/assets/grid.css" type="text/css" rel="stylesheet">
    <link href="/assets/main.css" type="text/css" rel="stylesheet">
  </head>

  <body>
  <!-- ... -->
  <script src="https://code.jquery.com/jquery-2.1.1.min.js" type="text/javascript"></script>
  <script src="/assets/application.js" type="text/javascript"></script>
  <script src="/assets/modals.js" type="text/javascript"></script>
  </body>
</html>
```

Let's have a look at the corresponding Ruby code.
In this example we use ERb, but remember that `Hanami::Assets` is compatible with
all the rendering engines such as HAML, Slim, Mustache, etc..

```ruby
require 'erb'
require 'hanami/assets'
require 'hanami/assets/helpers'

class View
  include Hanami::Assets::Helpers

  def initialize
    @template = File.read('template.erb')
    @engine   = ERB.new(@template)
  end

  def render
    @engine.result(binding)
  end
end

View.new.render # => HTML markup
```

For advanced configurations, please have a look at
[`Hanami::Assets::Configuration`](https://github.com/hanami/assets/blob/master/lib/hanami/assets/configuration.rb).

### Available Helpers

This gem ships with the following helpers:

  * `javascript`
  * `stylesheet`
  * `favicon`
  * `image`
  * `video`
  * `audio`
  * `asset_path`
  * `asset_url`

### Development mode

`Hanami::Assets` can help you during the development process of your application.
It can manage multiple source directories for each asset type or run a
preprocessor for you.

#### Sources

Imagine to have your application's javascripts under `app/assets/javascripts` and that
those assets depends on a vendored version of jQuery.

```ruby
require 'hanami/assets'

Hanami::Assets.configure do
  compile true

  sources << [
    'app/assets',
    'vendor/jquery'
  ]
end
```

When from a template you do:

```erb
<%= javascript 'jquery', 'jquery-ui', 'login' %>
```

`Hanami::Assets` looks at the defined sources and **lazily copies** those files
under `public/assets` (by default), before the markup is generated.

Your public directory will have the following structure.

```shell
% tree public
public/
└── assets
    ├── jquery.js
    ├── jquery-ui.js
    └── login.js

```

**Please remember that sources are recursively looked up in order of declaration.**

If in the example above we had a `jquery.js` under `app/assets/javascripts/**/*.js`
that file would be copied into the public directory instead of the one under
`vendor/jquery`. The reason is because we declared `app/assets/javascripts` first.

#### Preprocessors

`Hanami::Assets` is able to run assets preprocessors and **lazily compile** them
under `public/assets` (by default), before the markup is generated.

Imagine you have `main.css.scss` under `app/assets/stylesheets` and `reset.css` under
`vendor/stylesheets`.

**The two extensions are important.**
The first one is mandatory and it's used to understand which asset type we are
handling: `.css` for stylesheets.
The second one is optional and it's for a preprocessor: `.scss` for Sass.

```ruby
require 'sassc'
require 'hanami/assets'

Hanami::Assets.configure do
  compile true

  sources << [
    'assets',
    'vendor/assets'
  ]
end
```

And in a template you can use the `stylesheet` helper:

```erb
<%= stylesheet 'reset', 'main' %>
```

Your public directory will look like this:

```shell
% tree public
public/
└── assets
    ├── reset.css
    └── main.css
```

### Preprocessors engines

`Hanami::Assets` uses [Tilt](https://github.com/rtomayko/tilt) to provide support for the most common preprocessors, such as [Sass](http://sass-lang.com/) (including `sassc-ruby`), [Less](http://lesscss.org/), [ES6](https://babeljs.io/), [JSX](https://jsx.github.io/), [CoffeScript](http://coffeescript.org), [Opal](http://opalrb.com), [Handlebars](http://handlebarsjs.com), [JBuilder](https://github.com/rails/jbuilder).

In order to use one or more of them, be sure to add the corresponding gem to your `Gemfile` and require the library.

#### EcmaScript 6

We strongly suggest you use [EcmaScript 6](http://es6-features.org/) for your next project.
It isn't fully [supported](https://kangax.github.io/compat-table/es6/) yet by browsers, but it's the future of JavaScript.

As of today, you need to 'transpile' ES6 code into ES5, which current browsers understand.
The most popular tool for this is [Babel](https://babeljs.io), which we support.

### Deployment

`Hanami::Assets` ships with an executable (`hanami-assets`), which can be used to precompile assets and make them cacheable by browsers (via checksum suffix).

__NOTE__: If you're using `Hanami::Assets` with the full `Hanami` framework, you should use `bundle exec hanami assets precompile` instead of `hanami-assets`.

Let's say we have an application that has a main file that requires the entire codebase (`config/environment.rb`), a gem that brings in Ember.js code, and the following sources:

```shell
% tree .
├── apps
│   ├── admin
│   │   ├── assets
│   │   │   └── js
│   │   │       ├── application.js
│   │   │       └── zepto.js
# ...
│   ├── metrics
│   │   ├── assets
│   │   │   └── javascripts
│   │   │       └── dashboard.js
# ...
│   └── web
│       ├── assets
│       │   ├── images
│       │   │   └── bookshelf.jpg
│       │   └── javascripts
│       │       └── application.js
# ...
│       └── vendor
│           └── assets
│               └── javascripts
│                   └── jquery.js
└── config
    └── environment.rb
```

In order to deploy, we can run:

```shell
bundle exec hanami-assets --config=config/environment.rb
```

It will output:

```shell
tree public
public
├── assets
│   ├── admin
│   │   ├── application-28a6b886de2372ee3922fcaf3f78f2d8.js
│   │   ├── application.js
│   │   ├── ember-b2d6de1e99c79a0e52cf5c205aa2e07a.js
│   │   ├── ember-source-e74117fc6ba74418b2601ffff9eb1568.js
│   │   ├── ember-source.js
│   │   ├── ember.js
│   │   ├── zepto-ca736a378613d484138dec4e69be99b6.js
│   │   └── zepto.js
│   ├── application-d1829dc353b734e3adc24855693b70f9.js
│   ├── application.js
│   ├── bookshelf-237ecbedf745af5a477e380f0232039a.jpg
│   ├── bookshelf.jpg
│   ├── ember-b2d6de1e99c79a0e52cf5c205aa2e07a.js
│   ├── ember-source-e74117fc6ba74418b2601ffff9eb1568.js
│   ├── ember-source.js
│   ├── ember.js
│   ├── jquery-05277a4edea56b7f82a4c1442159e183.js
│   ├── jquery.js
│   └── metrics
│       ├── dashboard-7766a63ececc63a7a629bfb0666e9c62.js
│       ├── dashboard.js
│       ├── ember-b2d6de1e99c79a0e52cf5c205aa2e07a.js
│       ├── ember-source-e74117fc6ba74418b2601ffff9eb1568.js
│       ├── ember-source.js
│       └── ember.js
└── assets.json
```

#### Compressors

Minification is a process that shrinks file size in production, by removing unnecessary spaces and characters.
The goal of this step is to have lighter assets, which will be served faster to browsers.

Hanami supports JavaScript and stylesheet minifiers.

Because this framework relies on external gems for minification, this feature is **turned off by default**.

To use minification, we need to specify which gem we want to use and add it to our `Gemfile`.

##### JavaScript Compressors

Hanami can use the following compressors (aka minifiers) for JavaScript.

  * `:builtin` - Ruby based implementation of jsmin. It doesn't require any external gem.
  * `:yui` - [YUI Compressor](http://yui.github.io/yuicompressor), it depends on [`yui-compressor`](https://rubygems.org/gems/yui-compressor) gem and it requires Java 1.4+
  * `:uglifier` - [UglifyJS](http://lisperator.net/uglifyjs), it depends on [`uglifier`](https://rubygems.org/gems/uglifier) gem and it requires Node.js
  * `:closure` - [Google Closure Compiler](https://developers.google.com/closure/compiler), it depends on [`closure-compiler`](https://rubygems.org/gems/closure-compiler) gem and it requires Java

```ruby
Hanami::Assets.configure do
  javascript_compressor :uglifier
end
```

##### Stylesheet Compressors

Hanami can use the following compressors (aka minifiers) for stylesheets.

  * `:builtin` - Ruby based compressor. It doesn't require any external gem. It's fast, but not an efficient compressor.
  * `:yui` - [YUI Compressor](http://yui.github.io/yuicompressor), it depends on [`yui-compressor`](https://rubygems.org/gems/yui-compressor) gem and it requires Java 1.4+
  * `:sass` - [Sass](http://sass-lang.com/), it depends on [`sassc`](https://rubygems.org/gems/sassc) gem

```ruby
Hanami::Assets.configure do
  stylesheet_compressor :sass
end
```

##### Custom Compressors

We can specify our own minifiers:

```ruby
Hanami::Assets.configure do
  javascript_compressor MyJavascriptCompressor.new
  stylesheet_compressor MyStylesheetCompressor.new
end
```

### Fingerprint Mode

This is a mode that can be activated via configuration and it's suitable for production environments.
When generating files, it adds a string to the end of each file name, which is a [checksum](https://en.wikipedia.org/wiki/Checksum) of its contents.
This lets you leverage caching while still ensuring that clients get the most up-to-date assets (this is known as *cache busting*).

```ruby
Hanami::Assets.configure do
  fingerprint true
end
```

Once turned on, it will look at `/public/assets.json`, and helpers such as `javascript` will return a relative URL that includes the fingerprint of the asset.

```erb
<%= javascript 'application' %>
```

```html
<script src="/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>
```

### Subresource Integrity (SRI) Mode

This is a mode that can be activated via the configuration and it's suitable for production environments.

```ruby
Hanami::Assets.configure do
  subresource_integrity true
end
```

Once turned on, it will look at `/public/assets.json`, and helpers such as `javascript` will include an `integrity` and `crossorigin` attribute.

```erb
<%= javascript 'application' %>
```

```html
<script src="/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript" integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC" crossorigin="anonymous"></script>
```

### CDN Mode

A Hanami project can serve assets via a Content Delivery Network (CDN).

```ruby
Hanami::Assets.configure do
  scheme 'https'
  host   '123.cloudfront.net'
  port   443
  cdn    true
end
```

From now on, helpers will return the absolute URL for the asset, hosted on the CDN specified.

```erb
<%= javascript 'application' %>
```

```html
<script src="https://123.cloudfront.net/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>
```

## Third party gems

Developers can maintain gems that distribute assets for Hanami. For instance `hanami-ember` or `hanami-jquery`.

To do this, inside your gem you have tell `Hanami::Assets` where to look for assets:

```ruby
# lib/hanami/jquery.rb
Hanami::Assets.sources << '/path/to/jquery'
```

## Running tests

  * Make sure you have one of [ExecJS](https://github.com/rails/execjs)
supported runtime on your machine.
  * Java 1.4+ (for YUI Compressor and Google Closure Compiler)

```sh
bundle exec rake test
```

## Versioning

__Hanami::Assets__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/hanami/assets/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2017 Luca Guidi – Released under MIT License

This project was formerly known as Lotus (`lotus-assets`).
