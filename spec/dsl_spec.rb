require 'spec_helper'

class Minitest::Spec
  include Lotus::Assets::Dsl
end

describe Lotus::Assets::Dsl do
  after do
    Lotus::Assets.clear_configuration!
  end

  it 'should set the configured engine' do
    stylesheet_engine 'less'
    javascript_engine 'typescript'

    Lotus::Assets.stylesheet_engine.must_equal 'less'
    Lotus::Assets.javascript_engine.must_equal 'typescript'
  end

  it 'should set the configured path' do
    stylesheet_path 'css'
    javascript_path 'js'

    Lotus::Assets.stylesheet_path.must_equal 'css'
    Lotus::Assets.javascript_path.must_equal 'js'
  end

  it 'should set the configured file' do
    stylesheet_file 'main'
    javascript_file 'bootstrap'

    Lotus::Assets.stylesheet_file.must_equal 'main'
    Lotus::Assets.javascript_file.must_equal 'bootstrap'
  end

  it 'should set configured to_file option' do
    to_file true
    Lotus::Assets.to_file.must_equal true

    to_file false
    Lotus::Assets.to_file.must_equal false
  end

  it 'should have proper default options' do
    Lotus::Assets.stylesheet_engine.must_equal 'scss'
    Lotus::Assets.javascript_engine.must_equal 'coffee'

    Lotus::Assets.javascript_path.must_equal 'javascripts'
    Lotus::Assets.stylesheet_path.must_equal 'stylesheets'

    Lotus::Assets.javascript_file.must_equal 'application'
    Lotus::Assets.stylesheet_file.must_equal 'application'

    Lotus::Assets.to_file.must_equal true
  end
end
