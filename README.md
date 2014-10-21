# Lotus::Assets

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-assets'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-assets

## Usage

### Configuration

```ruby

Lotus::Assets.configure do
  assets_path 'assets'

  stylesheet_path 'stylesheets'
  javascript_path 'javascripts'

  path_prefix ''

  to_file true
end

```

This illustrates the whole configuration options with it's default values.

```assets_path``` - This is the real system path to your assets folder.

```stylesheet_path``` - This is the path from ```assets_path``` to your stylesheet folder

```javascript_path``` - This is the path from ```assets_path``` to your javascript folder

```path_prefix``` - The path_prefix will be used as prefix in the link and script href and src attribute

```to_file``` - If to_file is false the compiled css or js will be returned instead of a html link or script tag

### Standalone usage

[Example](examples/standalone)

### Semi-standalone usage (with Lotus::View but not full-stack)

[Example](examples/semi-standalone)

### Full-stack usage

TODO: Write Full-stack usage

## Contributing

1. Fork it ( https://github.com/[my-github-username]/lotus-assets/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
