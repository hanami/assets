require 'erb'

class View
  include Lotus::Assets::Helpers

  def self.template
    __dir__ + '/fixtures/template.erb'
  end

  def initialize
    @template = File.read(self.class.template)
  end

  def render
    ERB.new(@template).result(binding)
  end
end

class DefaultView < View
  def self.template
    __dir__ + '/fixtures/template.erb'
  end
end

class CustomAssetsPathView < View
  private
  def _javascript_prefix
    'custom-assets-path'
  end

  def _stylesheet_prefix
    'custom-assets-path-for-css'
  end
end

class CustomAssetsPrefix < View
  private
  def _assets_prefix
    'prefix'
  end
end
