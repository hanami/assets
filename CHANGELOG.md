# Hanami::Assets
Assets management for Ruby web applications

## v2.1.0 - 2023-11-14
### Changed
- [Tim Riley] Removed `bin/hanami-assets` executable

## v2.1.0.rc2 - 2023-11-08

## v2.1.0.rc1 - 2023-11-01

## v2.1.0.beta2 - 2023-10-04
### Added
- [Luca Guidi] Official support for Ruby: Ruby 3.1, and 3.2

### Changed
- [Luca Guidi] Drop support for Ruby: MRI 2 and JRuby
- [Luca Guidi] This gem now requires a working Node and Yarn installation
- [Tim Riley] Changed the gem to load using Zeitwerk, via `require "hanami/assets"`
- [Tim Riley] Changed `Hanami::Assets` to a class, initialized with a `Hanami::Assets::Config` (see below) and providing a `#[]` method returning a `Hanami::Assets::Asset` instance per asset.
- [Tim Riley] Moved `Hanami::Assets::Helpers` to `Hanami::Helpers::AssetsHelper` in the hanami gem (along with various helper methods renamed; see the hanami CHANGELOG for details)
- [Luca Guidi] Renamed `Hanami::Assets::Configuration` to `Config`
- [Luca Guidi] Removed `Hanami::Assets.configure`, use `Hanami::Assets::Config.new`
- [Luca Guidi] Removed `Hanami::Assets.deploy`, `.precompile`, `.load!` as precompile process is now handled via JavaScript
- [Luca Guidi] Removed `Hanami::Assets.sources`, as third-party libraries should be handled via Yarn
- [Luca Guidi] Removed `Hanami::Assets::Config#fingerprint`, as fingerprinting will be always activated
- [Luca Guidi] Changed `Hanami::Assets::Config#subresource_integrity`. To activate the feature, pass an array of algorithms to use (e.g. `config.subresource_integrity = ["sha-384"]`)
- [Luca Guidi] Removed `Hanami::Assets::Config#cdn`. To activate the feature, pass the CDN base URL to the initializer of the configuration (`base_url` keyword argument).
- [Luca Guidi] Removed `Hanami::Assets::Config#javascript_compressor` and `stylesheet_compressor`, as the compression is now handled via JavaScript
- [Luca Guidi] Removed `Hanami::Assets::Config#scheme`, `#host`, `#port`, and `#prefix`. Use `base_url` keyword argument to pass to configuration initializer
- [Luca Guidi] Removed `Hanami::Assets::Config#root`, `#public_directory`, `#destination_directory`, and `#manifest` as they will now looked up via conventions
- [Luca Guidi] Moved `Hanami::Assets::Precompiler` and `Watcher` to `hanami-cli`

## v1.3.5 - 2021-01-14
### Added
- [Luca Guidi] Official support for Ruby: MRI 3.0
- [Luca Guidi] Official support for Ruby: MRI 2.7

## v1.3.4 - 2019-10-11
### Fixed
- [unleashy] Precompile assets using binary mode to ensure compatibility with Windows

## v1.3.3 - 2019-09-13
### Fixed
- [Landon Grindheim] Lazily load `sassc` only when required
- [Landon Grindheim] Ensure assets precompilation to not crash when SASS stylesheet doesn't have dependencies

## v1.3.2 - 2019-08-02
### Added
- [Landon Grindheim & Sean Collins] Added support for `sassc` gem, because `sass` is no longer maintained

## v1.3.1 - 2019-01-18
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

### Fixed
- [Luca Guidi] Make optional nested assets feature to maintain backward compatibility with `1.2.x`

## v1.3.0 - 2018-10-24

## v1.3.0.beta1 - 2018-08-08
### Added
- [Paweł Świątkowski] Preserve directory structure of assets at the precompile time.
- [Luca Guidi] Official support for JRuby 9.2.0.0

## v1.2.0 - 2018-04-11

## v1.2.0.rc2 - 2018-04-06

## v1.2.0.rc1 - 2018-03-30

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28
### Added
- [Luca Guidi] Collect assets informations for Early Hints (103)
- [Luca Guidi] Send automatically javascripts and stylesheets via Push Promise / Early Hints
- [Luca Guidi] Add the ability to send audio, video, and generic assets for Push Promise / Early Hints

## v1.1.1 - 2018-02-27
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.5

### Fixed
- [Malina Sulca] Print `href` and `src` first in output HTML

## v1.1.0 - 2017-10-25
### Fixed
- [Luca Guidi] Don't let `#javascript` and `#stylesheet` helpers to append file extension if the URL contains a query string

## v1.1.0.rc1 - 2017-10-16

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03

## v1.1.0.beta1 - 2017-08-11

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

## v1.0.0.beta2 - 2017-03-17

## v1.0.0.beta1 - 2017-02-14
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.4

## v0.4.0 - 2016-11-15
### Fixed
- [Luca Guidi] Ensure `NullManifest` to be pretty printable

### Changed
- [Luca Guidi] Official support for Ruby: MRI 2.3+ and JRuby 9.1.5.0+
- [Sean Collins] Rename digest into fingerprint

## v0.3.0 - 2016-07-22
### Added
- [Matthew Gibbons & Sean Collins] Subresource Integrity (SRI)
- [Matthew Gibbons & Sean Collins] Allow `javascript` and `stylesheet` helpers to accept a Hash representing HTML attributes. Eg. `<%= javascript 'application', async: true %>`

### Fixed
- [Alexander Gräfe] Safely precompile assets from directories with a dot in their name.
- [Luca Guidi] Detect changes for Sass/SCSS dependencies.
- [Maxim Dorofienko & Luca Guidi] Preserve static assets under public directory, by removing only assets directory and manifest at the precompile time.

### Changed
– [Luca Guidi] Drop support for Ruby 2.0 and 2.1. Official support for JRuby 9.0.5.0+.
- [Luca Guidi] Don't create digest version of files under public directory, but only for precompiled files.

## v0.2.1 - 2016-02-05
### Changed
- [Derk-Jan Karrenbeld] Don't precompile `.map` files

### Fixed
- [Luca Guidi] Fix recursive Sass imports
- [Luca Guidi] Ensure to truncate assets in public before to precompile/copy them

## v0.2.0 - 2016-01-22
### Changed
- [Luca Guidi] Renamed the project

## v0.1.0 - 2016-01-12
### Added
- [Luca Guidi] Configurable assets compressors
- [Luca Guidi] Builtin JavaScript and stylesheet compressors
- [deepj & Michael Deol] Added `Lotus::Assets::Helpers#favicon`
- [Leigh Halliday] Added `Lotus::Assets::Helpers#video`
- [Kleber Correia] Added `Lotus::Assets::Helpers#audio`
- [Gonzalo Rodríguez-Baltanás Díaz] Added `Lotus::Assets::Helpers#image`
- [Luca Guidi] Added `Lotus::Assets::Helpers#javascript` and `#stylesheet`
- [Luca Guidi] Added `Lotus::Assets::Helpers#asset_path` and `#asset_url`
- [Luca Guidi] "CDN Mode" let helpers to generate CDN URLs (eg. `https://123.cloudfront.net/assets/application-d1829dc353b734e3adc24855693b70f9.js`)
- [Luca Guidi] "Digest Mode" let helpers to generate digest URLs (eg. `/assets/application-d1829dc353b734e3adc24855693b70f9.js`)
- [Luca Guidi] Added `hanami-assets` command to precompile assets at the deploy time
- [Luca Guidi] Added support for third party gems that want to ship gemified assets for Lotus
- [Luca Guidi] Assets preprocessors (eg. Sass, ES6, CoffeeScript, Opal, JSX)
- [Luca Guidi] Official support for Ruby 2.0+
