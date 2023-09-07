# Hanami::Assets

Assets management for Ruby web projects

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-assets.svg)](https://badge.fury.io/rb/hanami-assets)
[![CI](https://github.com/hanami/assets/workflows/ci/badge.svg?branch=main)](https://github.com/hanami/assets/actions?query=workflow%3Aci+branch%3Amain)
[![Test Coverage](https://codecov.io/gh/hanami/assets/branch/main/graph/badge.svg)](https://codecov.io/gh/hanami/assets)
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

__Hanami::Assets__ supports Ruby (MRI) 3.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hanami-assets"
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

### Command Line (CLI)

During development run `bundle exec hanami server`.
Your app will start the assets management.

### Helpers

Hanami Assets provides asset-specific helpers to be used in templates.
They resolve one or multiple sources into corresponding HTML tags.
Those sources can be either a name of a local asset or an absolute URL.

Given the following template:

```erb
<!doctype HTML>
<html>
  <head>
    <title>Assets example</title>
    <%= assets.css "reset", "app" %>
  </head>

  <body>
  <!-- ... -->
  <%= assets.js "app" %>
  <%= assets.js "https://cdn.somethirdparty.script/foo.js", async: true %>
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
    <link href="/assets/app.css" type="text/css" rel="stylesheet">
  </head>

  <body>
  <!-- ... -->
  <script src="/assets/app.js" type="text/javascript"></script>
  <script src="https://cdn.somethirdparty.script/foo.js" type="text/javascript" async></script>
  </body>
</html>
```

### Available Helpers

This gem ships with the following helpers:

  * `javascript` (aliased as `js`)
  * `stylesheet` (aliased as `css`)
  * `favicon`
  * `image` (aliased as `img`)
  * `video`
  * `audio`
  * `path`

## App Structure

Hanami applications are generated via `hanami new` CLI command.

Among other directories, it generates a specific structure for assets:

```shell
$ tree app/assets
├── images
│   └── favicon.ico
├── javascripts
│   └── app.ts
└── stylesheets
    └── app.css
```

#### Entry Points

Entry Points are the JavaScript files or modules that serve as the starting points of your application.
They define the scope of your bundling process and determine which parts of your code will be included in the final output.
By understanding the dependencies of your entry points, Hanami Assets can create efficient and optimized bundles for your JavaScript or TypeScript applications.

When Hanami Assets encounters an import or require statement for an asset, it process the asset file to the output directory.
This process includes any kind of asset: other JavaScript files, stylesheets, images **referenced from the Entry Point**.

The default entry points are:

  * `app/assets/javascripts/app.ts`
  * `slices/[slice-name]/assets/javascripts/app.ts`

You can specify custom Entry Points, by adding an `app.{js,ts,mjs,mts,tsx,jsx}` file into the assets directory of the app or a slice.

An example is: `app/assets/javascripts/login/app.ts` to define a new Entry Point for a Login page where you want to have a more lightweight bundle.

#### Static Assets

Except for `javascripts` and `stylesheets` directories, all the other directories are considered **static**.
Their files will be copied as they are to the destination directory.

If you have a custom directory `app/assets/fonts`, all the fonts are copied to the destination direcotry.

#### Destination Directory

The destination directory is `public/assets`.

### Sources

Hanami Assets works with [Yarn](https://yarnpkg.com/).

In order to add/remove a source to your application, you should follow Yarn's dependencies management.

### Preprocessors

Hanami Assets is able to preprocess any kind of JavaScript and CSS flavor.

### Deployment

To process the assets during deployment run `bundle exec hanami assets precompile`.

The destination directory will contain the processed assets with an hashed name.

#### Fingerprint Mode

Asset fingerprinting is a technique that involves adding a unique identifier to the filenames of static assets to ensure cache-busting.
By doing so, you can safely cache and deliver updated versions of assets to client browsers, avoiding the use of outdated cached versions and ensuring a consistent and up-to-date user experience.

During the deployment process, Hanami Assets appends to the file name a unique hash.

Example: `app/assets/javascripts/app.ts` -> `public/assets/app-QECGTTYG.js`

It creates a `/public/assets.json` to map the original asset name to the fingerprint name.

The simple usage of the `js` helper, will be automatically mapped for you:

```erb
<%= assets.js "app" %>
```

```html
<script src="/assets/app-QECGTTYG.js" type="text/javascript"></script>
```

#### Subresource Integrity (SRI) Mode

Subresource Integrity (SRI) is a security mechanism that allows browsers to verify the integrity of external resources by comparing their content against a cryptographic hash. It helps protect against unauthorized modifications to external scripts and enhances the security and trustworthiness of web applications.

```ruby
module MyApp
  class App < Hanami::App
    config.assets.subresource_integrity = ["sha-384"]
  end
end
```

Once turned on, it will look at `/public/assets.json`, and helpers such as `javascript` will include an `integrity` and `crossorigin` attribute.

```erb
<%= assets.js "app" %>
```

```html
<script src="/assets/app-QECGTTYG.js" type="text/javascript" integrity="sha384-d9ndh67iVrvaACuWjEDJDJlThKvAOdILG011RxYJt1dQynvf4JXNORcUiZ9nO7lP" crossorigin="anonymous"></script>
```

#### Content Delivery Network (CDN) Mode

A Content Delivery Network (CDN) is a globally distributed network of servers strategically located in multiple geographical locations.
CDNs are designed to improve the performance, availability, and scalability of websites and web applications by reducing latency and efficiently delivering content to end users.

A Hanami project can serve assets via a Content Delivery Network (CDN).

```ruby
module MyApp
  class App < Hanami::App
    config.assets.base_url = "https://123.cloudfront.net"
  end
end
```

From now on, helpers will return the absolute URL for the asset, hosted on the CDN specified.

```erb
<%= javascript 'application' %>
```

```html
<script src="https://123.cloudfront.net/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>
```

```erb
<%= assets.js "app" %>
```

```html
<script src="https://123.cloudfront.net/assets/app-QECGTTYG.js" type="text/javascript"></script>
```

NOTE: We suggest to use SRI mode when using CDN.

## Development

Install:

  * Node
  * NPM

```bash
$ npm install
$ bundle exec rake test
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

Copyright © 2014-2023 Hanami Team – Released under MIT License
