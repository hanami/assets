require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Assets.configure do
      assets_path "#{Lotus::Assets.root}/test/fixtures"

      javascript_path 'javascripts'
      stylesheet_path 'stylesheets'

      path_prefix 'prefix/'

      to_file true
    end
  end

  after do
    Lotus::Assets.configuration.clear!
  end

  it 'should set proper options' do
    Lotus::Assets.configuration.assets_path.must_equal "#{Lotus::Assets.root}/test/fixtures"

    Lotus::Assets.configuration.javascript_path.must_equal 'javascripts'
    Lotus::Assets.configuration.stylesheet_path.must_equal 'stylesheets'

    Lotus::Assets.configuration.path_prefix.must_equal 'prefix/'

    Lotus::Assets.configuration.to_file.must_equal true
  end
end
