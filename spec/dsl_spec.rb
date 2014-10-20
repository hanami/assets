require 'spec_helper'

class Minitest::Spec
  include Lotus::Assets::Dsl
end

describe Lotus::Assets::Dsl do
  after do
    Lotus::Assets.clear_configuration!
  end

  it 'should set the configured path' do
    stylesheet_path 'css'
    javascript_path 'js'

    Lotus::Assets.stylesheet_path.must_equal 'css'
    Lotus::Assets.javascript_path.must_equal 'js'
  end

  it 'should set the configured path_prefix' do
    path_prefix '/admin'
    Lotus::Assets.path_prefix.must_equal '/admin'

    path_prefix '/backend'
    Lotus::Assets.path_prefix.must_equal '/backend'
  end

  it 'should set configured to_file option' do
    to_file true
    Lotus::Assets.to_file.must_equal true

    to_file false
    Lotus::Assets.to_file.must_equal false
  end

  it 'should have proper default options' do
    Lotus::Assets.javascript_path.must_equal 'javascripts'
    Lotus::Assets.stylesheet_path.must_equal 'stylesheets'

    Lotus::Assets.to_file.must_equal true
    Lotus::Assets.path_prefix.must_equal ''
  end
end
