if ENV['COVERAGE']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    add_filter '.gem/'
  end
end

gem 'minitest'

require 'minitest/autorun'
require 'minitest/reporters'
require 'lotus/assets'

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

module Lotus
  module Assets
    module_function

    ##
    # Method to return Gem Root Dir from everywhere in the test suite
    #
    # @return [String] Gem Root Folder
    def root
      ::File.dirname(::File.expand_path('..', __FILE__))
    end
  end
end

Lotus::Assets::ALLOWED_FIXTURES = [
  "#{Lotus::Assets.root}/test/fixtures/stylesheets/application.scss",
  "#{Lotus::Assets.root}/test/fixtures/stylesheets/compiled.css",
  "#{Lotus::Assets.root}/test/fixtures/javascripts/application.coffee",
  "#{Lotus::Assets.root}/test/fixtures/javascripts/compiled.js"
]

class Minitest::Spec
  include Lotus::Assets::Helpers
end
