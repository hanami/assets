require 'test_helper'

describe 'when including a file' do
  before do
    Lotus::Assets.configure do
      assets_path "#{Lotus::Assets.root}/test/fixtures"

      javascript_path 'javascripts'
      stylesheet_path 'stylesheets'

      path_prefix 'prefix/'

      to_file true
    end

    @stylesheet_tag = stylesheet 'application'
    @javascript_tag = javascript 'application'
  end

  after do
    assets = []
    assets_dirs = Dir["#{assets_path}/*"]
    assets_dirs.each do |dir|
      assets << Dir["#{dir}/*"]
    end

    assets = assets.flatten(1)
    created = assets - Lotus::Assets::ALLOWED_FIXTURES
    created.each do |file|
      system("rm #{file}")
    end

    Lotus::Assets.configuration.clear!
  end

  it 'should contain the path prefix' do
    @stylesheet_tag.must_include 'prefix/'
    @javascript_tag.must_include 'prefix/'
  end

  it 'should return the proper html tag' do
    @stylesheet_tag.must_include 'link'
    @stylesheet_tag.must_include "rel='stylesheet'"
    @stylesheet_tag.must_include 'href'

    @javascript_tag.must_include 'script'
    @javascript_tag.must_include 'src'
  end

  it 'should contain the javascript / stylesheet path' do
    @stylesheet_tag.must_include 'stylesheets'
    @javascript_tag.must_include 'javascripts'
  end

  describe 'when nonexisting' do
    it 'should raise a NoFilesFoundException' do
      lambda { stylesheet 'nonexisting' }.must_raise Lotus::Assets::FilesNotFoundException
      lambda { javascript 'nonexisting' }.must_raise Lotus::Assets::FilesNotFoundException
    end
  end
end
