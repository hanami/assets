require 'spec_helper'
require 'tilt'

class Minitest::Spec
  include Lotus::Assets::Dsl
  include Lotus::Assets::AssetsHelpers
end

describe Lotus::Assets::AssetsHelpers do
  before do
    Lotus::Assets.assets_path = "#{Lotus::Assets.root}/spec/fixtures"

    @assets = []
    assets_dirs = Dir["#{Lotus::Assets.assets_path}/*"]
    assets_dirs.each do |dir|
      @assets << Dir["#{dir}/*"]
    end

    @assets = @assets.flatten(1)
  end

  after do
    Lotus::Assets.assets_path = "#{Lotus::Assets.root}/spec/fixtures"

    after_assets = []
    assets_dirs = Dir["#{Lotus::Assets.assets_path}/*"]
    assets_dirs.each do |dir|
      after_assets << Dir["#{dir}/*"]
    end

    after_assets = after_assets.flatten(1)

    created = after_assets - @assets
    created.each do |file|
      system("rm #{file}")
    end

    Lotus::Assets.clear_configuration!
  end

  it 'compiles a given scss file into the proper css file' do
    stylesheet_path   'stylesheets'

    stylesheet

    File.exist?("#{Lotus::Assets.assets_path}/#{stylesheet_path}/application.css").must_equal true
  end

  it 'includes the proper stylesheet html tag' do
    stylesheet_path   'stylesheets'
    path_prefix       '/admin'

    stylesheet.must_include 'link'
    stylesheet.must_include "rel='stylesheet'"
    stylesheet.must_include 'stylesheets/application.css'
    stylesheet.must_include '/admin'
  end

  it 'compiles a given coffee file into the proper js file' do
    javascript_path   'javascripts'

    javascript

    File.exist?("#{Lotus::Assets.assets_path}/#{javascript_path}/application.js").must_equal true
  end

  it 'includes the proper script html tag' do
    javascript_path   'javascripts'
    path_prefix       '/admin'

    javascript.must_include 'script'
    javascript.must_include 'javascripts/application.js'
    javascript.must_include '/admin'
  end

  it 'returns the compiled sass if to_file is disabled' do
    stylesheet_path 'stylesheets'
    to_file false

    stylesheet.must_include 'body {'
  end

  it 'returns the compiled coffescript if to_file is disabled' do
    javascript_path 'javascripts'
    to_file false

    javascript.must_include 'alert'
  end
end
