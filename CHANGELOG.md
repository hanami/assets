# Hanami::Assets
Assets management for Ruby web applications

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
