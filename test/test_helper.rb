require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'
    add_filter   'test'
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require 'lotus/assets'
require 'fixtures'
require 'pathname'

TMP = Pathname.new(__dir__).join('..', 'tmp')
TMP.mkpath

Lotus::Utils::LoadPaths.class_eval do
  def empty?
    @paths.empty?
  end

  def clear
    @paths.clear
  end

  def include?(path)
    @paths.include?(path)
  end

  def delete(path)
    @paths.delete(path)
  end
end

Lotus::Assets::Config::GlobalSources.class_eval do
  def clear
    synchronize do
      @paths.each do |path|
        Lotus::Assets.configuration.sources.delete(path)

        Lotus::Assets.duplicates.each do |duplicate|
          duplicate.configuration.sources.delete(path)
        end
      end

      super
    end
  end
end
