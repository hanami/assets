require 'rubygems'
require 'bundler/setup'

if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'
$:.unshift 'lib'
require 'hanami/assets'
require 'fixtures'
require 'pathname'

TMP = Pathname.new(__dir__).join('..', 'tmp')
TMP.mkpath

Hanami::Utils::LoadPaths.class_eval do
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

Hanami::Assets::Config::GlobalSources.class_eval do
  def clear
    @paths.each do |path|
      Hanami::Assets.configuration.sources.delete(path)

      Hanami::Assets.duplicates.each do |duplicate|
        duplicate.configuration.sources.delete(path)
      end
    end

    super
  end
end
