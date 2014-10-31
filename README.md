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
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-assets
* Bugs/Issues: https://github.com/lotus/assets/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Chat: https://gitter.im/lotus/chat

## Rubies

__Lotus::Assets__ supports Ruby (MRI) 2+ and JRuby 1.7 (with 2.0 mode).

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

### Development mode

`Lotus::Assets` can help you during the development process of your application.
It can manage multiple source directories for each asset type or run a
preprocessor for you.


#### Sources

Imagine to have your application's javascripts under `app/javascripts` and that
those assets depends on a vendored version of jQuery.

```ruby
require 'lotus/assets'

Lotus::Assets.configure do
  compile true

  define :javascript do
    sources << [
      'app/javascripts',
      'vendor/jquery'
    ]
  end
end
```

When from a template you do:

```erb
<%= javascript 'jquery', 'jquery-ui', 'login' %>
```

`Lotus::Assets` looks at the defined sources and **lazily copies** those files
under `public/assets` (by default), before the markup is generated.

Your destination directory will have the following structure.

```shell
% tree public
public/
└── assets
    ├── jquery.js
    ├── jquery-ui.js
    └── login.js

```

**Please remember that sources are recursively looked up in order of declaration.**

If in the example above we had a `jquery.js` under `app/javascripts/**/*.js`
that file would be copied into the destination folder instead of the one under
`vendor/jquery`. The reason is because we declared `app/javascripts` first.

#### Preprocessors

`Lotus::Assets` is able to run assets preprocessors and **lazily compile** them
under `public/assets` (by default), before the markup is generated.

Imagine to have `main.css.scss` under `app/stylesheet` and `reset.css` under
`vendor/stylesheets`.

**The extensions structure is important.**
The first one is mandatory and it's used to understand which asset type we are
handling: `.css` for stylesheets.
The second one is optional and it's for a preprocessor: `.scss` for SASS.

```ruby
require 'sass'
require 'lotus/assets'

Lotus::Assets.configure do
  compile true

  define :stylesheet do
    sources << [
      'app/stylesheet',
      'vendor/stylesheets'
    ]
  end
end
```

When from a template you do:

```erb
<%= stylesheet 'reset', 'main' %>
```

Your destination directory will have the following structure.

```shell
% tree public
public/
└── assets
    ├── reset.css
    └── main.css
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

Copyright 2014 Luca Guidi – Released under MIT License
