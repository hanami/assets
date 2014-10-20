if ENV['COVERAGE']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start
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
