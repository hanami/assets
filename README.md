# Lotus::Assets

Assets management for Ruby web projects

## Status

[![Gem Version](http://img.shields.io/gem/v/lotus-assets.svg)](https://badge.fury.io/rb/lotus-assets)
[![Build Status](http://img.shields.io/travis/lotus/assets/master.svg)](https://travis-ci.org/lotus/assets?branch=master)
[![Coverage](http://img.shields.io/coveralls/lotus/assets/master.svg)](https://coveralls.io/r/lotus/assets)
[![Code Climate](http://img.shields.io/codeclimate/github/lotus/assets.svg)](https://codeclimate.com/github/lotus/assets)
[![Dependencies](http://img.shields.io/gemnasium/lotus/assets.svg)](https://gemnasium.com/lotus/assets)
[![Inline Docs](http://inch-ci.org/github/lotus/assets.svg)](http://inch-ci.org/github/lotus/assets)

## Contact

* Home page: http://lotusrb.org
* Community: http://lotusrb.org/community
* Guides: http://lotusrb.org/guides
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-assets
* Bugs/Issues: https://github.com/lotus/assets/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Forum: https://discuss.lotusrb.org
* Chat: http://chat.lotusrb.org

## Rubies

__Lotus::Assets__ supports Ruby (MRI) 2+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-assets'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install lotus-assets
```

## Usage

### Helpers

The framework offers assets specific helpers to be used in templates.
They resolve one or multiple sources into corresponding HTML tags.
Those sources can be the name of the local asset or an absolute URL.

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

It will output this markup.

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
In this example we use ERb, but remember that `Lotus::Assets` is compatible with
all the rendering engines such as HAML, Slim, Mustache, etc..

```ruby
require 'erb'
require 'lotus/assets'
require 'lotus/assets/helpers'

class View
  include Lotus::Assets::Helpers

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
[`Lotus::Assets::Configuration`](https://github.com/lotus/assets/blob/master/lib/lotus/assets/configuration.rb).

### Available Helpers

This gems ships with the following helpers:

  * `javascript`
  * `stylesheet`
  * `favicon`
  * `image`
  * `video`
  * `audio`
  * `asset_path`
  * `asset_url`

### Development mode

`Lotus::Assets` can help you during the development process of your application.
It can manage multiple source directories for each asset type or run a
preprocessor for you.

#### Sources

Imagine to have your application's javascripts under `app/assets/javascripts` and that
those assets depends on a vendored version of jQuery.

```ruby
require 'lotus/assets'

Lotus::Assets.configure do
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

`Lotus::Assets` looks at the defined sources and **lazily copies** those files
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

`Lotus::Assets` is able to run assets preprocessors and **lazily compile** them
under `public/assets` (by default), before the markup is generated.

Imagine to have `main.css.scss` under `app/assets/stylesheets` and `reset.css` under
`vendor/stylesheets`.

**The extensions structure is important.**
The first one is mandatory and it's used to understand which asset type we are
handling: `.css` for stylesheets.
The second one is optional and it's for a preprocessor: `.scss` for Sass.

```ruby
require 'sass'
require 'lotus/assets'

Lotus::Assets.configure do
  compile true

  sources << [
    'assets',
    'vendor/assets'
  ]
end
```

When from a template you do:

```erb
<%= stylesheet 'reset', 'main' %>
```

Your public directory will have the following structure.

```shell
% tree public
public/
└── assets
    ├── reset.css
    └── main.css
```

### Preprocessors engines

`Lotus::Assets` uses [Tilt](https://github.com/rtomayko/tilt) to provide support for the most common preprocessors, such as [Sass](http://sass-lang.com/) (including `sassc-ruby`), [Less](http://lesscss.org/), ES6, [JSX](https://jsx.github.io/), [CoffeScript](http://coffeescript.org), [Opal](http://opalrb.org), [Handlebars](http://handlebarsjs.com), [JBuilder](https://github.com/rails/jbuilder).

In order to use one or more of them, be sure to include the corresponding gem into your `Gemfile` and require the library.

#### EcmaScript 6

We strongly suggest to use [EcmaScript 6](http://es6-features.org/) for your next project.
It isn't fully [supported](https://kangax.github.io/compat-table/es6/) yet by browser vendors, but it's the future of JavaScript.

As of today, you need to transpile ES6 code into something understandable by current browsers, which is ES5.
For this purpose we support [Babel](https://babeljs.io).

### Deployment

`Lotus::Assets` ships with an executable (`lotus-assets`), which can be used to precompile assets and make them cacheable by browsers (via checksum suffix).

Let's say we have an application that has main file that requires the entire code (`config/environment.rb`), a gem that brings Ember.js code, and the following sources:

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
bundle exec lotus-assets --config=config/environment.rb
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

Minification is a process that shrink file size in production, by removing unnecessary spaces and characters.
The goal of this step, is to have lighter assets to be served faster to the browsers.

Lotus supports JavaScript and stylesheets minifiers.

Because this framework relies on external gems for minification, this feature is **turned off by default**.

To do so we need to specify which gem we want to use and add it to our `Gemfile`.

##### JavaScript Compressors

Lotus can use the following compressors (aka minifiers) for JavaScript.

  * `:builtin` - Ruby based implementation of jsmin. It doesn't require any external gem.
  * `:yui` - [YUI Compressor](http://yui.github.io/yuicompressor), it depends on [`yui-compressor`](https://rubygems.org/gems/yui-compressor) gem and iπt requires Java 1.4+
  * `:uglifier` - [UglifyJS](http://lisperator.net/uglifyjs), it depends on [`uglifier`](https://rubygems.org/gems/uglifier) gem and it requires Node.js
  * `:closure` - [Google Closure Compiler](https://developers.google.com/closure/compiler), it depends on [`closure-compiler`](https://rubygems.org/gems/closure-compiler) gem and it requires Java

```ruby
Lotus::Assets.configure do
  javascript_compressor :uglifier
end
```

##### Stylesheet Compressors

Lotus can use the following compressors (aka minifiers) for Stylesheet.

  * `:builtin` - Ruby based compressor. It doesn't require any external gem. It's fast, but not an efficient compressor.
  * `:yui` - [YUI Compressor](http://yui.github.io/yuicompressor), it depends on [`yui-compressor`](https://rubygems.org/gems/yui-compressor) gem and iπt requires Java 1.4+
  * `:sass` - [Sass](http://sass-lang.com/), it depends on [`sass`](https://rubygems.org/gems/sass) gem

```ruby
Lotus::Assets.configure do
  stylesheet_compressor :sass
end
```

##### Custom Compressors

We can specify our own minifiers:

```ruby
Lotus::Assets.configure do
  javascript_compressor MyJavascriptCompressor.new
  stylesheet_compressor MyStylesheetCompressor.new
end
```

### Digest Mode

This is a mode that can be activated via the configuration and it's suitable for production environments.

```ruby
Lotus::Assets.configure do
  digest true
end
```

Once turned on, it will look at `/public/assets.json`, and helpers such as `javascript` will return a relative URL that includes the digest of the asset.

```erb
<%= javascript 'application' %>
```

```html
<script src="/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>
```

### CDN Mode

A Lotus project can serve assets via CDN.

```ruby
Lotus::Assets.configure do
  scheme 'https'
  host   '123.cloudfront.net'
  port   443
  cdn    true
end
```

Since now on, helpers will return the CDN absolute URL for the asset.

```erb
<%= javascript 'application' %>
```

```html
<script src="https://123.cloudfront.net/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>
```

## Third party gems

Developers can maintain gems that distribute assets for Lotus. For instance `lotus-ember` or `lotus-jquery`.

As a gem developer, you must add one or more paths, where the assets are stored inside the gem.

```ruby
# lib/lotus/jquery.rb
Lotus::Assets.sources << '/path/to/jquery'
```

## Running tests

  * Make sure you have one of [ExecJS](https://github.com/rails/execjs)
supported runtime on your machine.
  * Java 1.4+

```sh
bundle exec rake test
```

## Versioning

__Lotus::Assets__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/lotus/assets/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2016 Luca Guidi – Released under MIT License
