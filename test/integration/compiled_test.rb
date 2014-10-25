require 'test_helper'

describe 'when including a compiled file' do
  before do
    Lotus::Assets.configure do
      assets_path "#{Lotus::Assets.root}/test/fixtures"

      javascript_path 'javascripts'
      stylesheet_path 'stylesheets'

      path_prefix 'prefix/'

      to_file true
    end

    @stylesheet_tag = stylesheet 'compiled'
    @javascript_tag = javascript 'compiled'
  end

  after do
    Lotus::Assets.configuration.clear!
  end

  it 'should include the already compiled file' do
    @stylesheet_tag.must_include 'link'
    @stylesheet_tag.must_include "rel='stylesheet'"
    @stylesheet_tag.must_include 'href'
    @stylesheet_tag.must_include 'compiled.css'

    @javascript_tag.must_include 'script'
    @javascript_tag.must_include 'src'
    @javascript_tag.must_include 'compiled.js'
  end
end
