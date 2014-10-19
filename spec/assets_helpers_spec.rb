require 'spec_helper'
require 'tilt'

class Minitest::Spec
  include Lotus::Assets::Dsl
  include Lotus::Assets::AssetsHelpers
end

describe Lotus::Assets::AssetsHelpers do
  before do
    Lotus::Assets.path = "#{Lotus::Assets.root}/spec/fixtures"

    @assets = []
    assets_dirs = Dir["#{Lotus::Assets.path}/*"]
    assets_dirs.each do |dir|
      @assets << Dir["#{dir}/*"]
    end

    @assets = @assets.flatten(1)
  end

  after do
    Lotus::Assets.path = "#{Lotus::Assets.root}/spec/fixtures"

    after_assets = []
    assets_dirs = Dir["#{Lotus::Assets.path}/*"]
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
    stylesheet_engine 'scss'
    stylesheet_path   'stylesheets'
    stylesheet_file   'application'

    stylesheet_include_tag

    File.exist?("#{Lotus::Assets.path}/#{stylesheet_path}/#{stylesheet_file}.#{stylesheet_engine}").must_equal true
  end

  it 'includes the proper stylesheet html tag' do
    stylesheet_engine 'scss'
    stylesheet_path   'stylesheets'
    stylesheet_file   'application'

    stylesheet_include_tag.must_include 'link'
    stylesheet_include_tag.must_include "rel='stylesheet'"
    stylesheet_include_tag.must_include 'stylesheets/application.css'
  end

  it 'compiles a given coffee file into the proper js file' do
    javascript_engine 'coffee'
    javascript_path   'javascripts'
    javascript_file   'application'

    javascript_include_tag

    File.exist?("#{Lotus::Assets.path}/#{javascript_path}/#{javascript_file}.#{javascript_engine}").must_equal true
  end

  it 'includes the proper script html tag' do
    javascript_engine 'coffee'
    javascript_path   'javascripts'
    javascript_file   'application'

    javascript_include_tag.must_include 'script'
    javascript_include_tag.must_include 'javascripts/application.js'
  end

  it 'returns the compiled sass if to_file is disabled' do
    stylesheet_engine 'scss'
    stylesheet_path 'stylesheets'
    stylesheet_file 'application'
    to_file false

    stylesheet_include_tag.must_include 'body {'
  end

  it 'returns the compiled coffescript if to_file is disabled' do
    javascript_engine 'coffee'
    javascript_path 'javascripts'
    javascript_file 'application'
    to_file false

    javascript_include_tag.must_include 'alert'
  end
end
