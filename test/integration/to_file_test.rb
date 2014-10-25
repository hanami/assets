require 'test_helper'



describe 'to_file Option is disabled' do
  describe 'when including a file' do
    before do
      Lotus::Assets.configure do
        assets_path "#{Lotus::Assets.root}/test/fixtures"

        javascript_path 'javascripts'
        stylesheet_path 'stylesheets'

        path_prefix 'prefix/'

        to_file false
      end

      @stylesheet = stylesheet 'application'
      @javascript = javascript 'application'
    end

    after do
      Lotus::Assets.configuration.clear!
    end

    it 'should return the compiled css / js' do
      @stylesheet.must_include 'body'
      @javascript.must_include 'alert'
    end
  end
end
