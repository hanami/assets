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
  def javascript_prefix
    'custom-assets-path'
  end

  def stylesheet_prefix
    'custom-assets-path-for-css'
  end
end

class CustomAssetsPrefix < View
  private
  def assets_prefix
    'prefix'
  end
end

class RenderMultipleAssets < View
  def self.template
    __dir__ + '/fixtures/multi-template.erb'
  end
end

class AbsoluteUrlsView < View
  def self.template
    __dir__ + '/fixtures/absolute-urls-template.erb'
  end
end
