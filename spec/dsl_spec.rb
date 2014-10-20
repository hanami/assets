require 'spec_helper'

class Minitest::Spec
  include Lotus::Assets::Dsl
end

describe Lotus::Assets::Dsl do
  after do
    Lotus::Assets.configuration.clear!
  end

  it 'should set the configured assets_path' do
    assets_path 'path/to/public'

    Lotus::Assets.configuration.assets_path.must_equal 'path/to/public'
  end

  it 'should set the configured path' do
    stylesheet_path 'css'
    javascript_path 'js'

    Lotus::Assets.configuration.stylesheet_path.must_equal 'css'
    Lotus::Assets.configuration.javascript_path.must_equal 'js'
  end

  it 'should set the configured path_prefix' do
    path_prefix '/admin'
    Lotus::Assets.configuration.path_prefix.must_equal '/admin'

    path_prefix '/backend'
    Lotus::Assets.configuration.path_prefix.must_equal '/backend'
  end

  it 'should set configured to_file option' do
    to_file true
    Lotus::Assets.configuration.to_file.must_equal true

    to_file false
    Lotus::Assets.configuration.to_file.must_equal false
  end

  it 'should have proper default options' do
    Lotus::Assets.configuration.assets_path.must_equal 'assets'
    Lotus::Assets.configuration.javascript_path.must_equal 'javascripts'
    Lotus::Assets.configuration.stylesheet_path.must_equal 'stylesheets'

    Lotus::Assets.configuration.to_file.must_equal true
    Lotus::Assets.configuration.path_prefix.must_equal ''
  end
end
