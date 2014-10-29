require 'erb'

class View
  include Lotus::Assets::Helpers

  def self.template
    __dir__ + '/fixtures/template.erb'
  end

  def initialize
    @engine = ERB.new(
      File.read(self.class.template)
    )
  end

  def render
    @engine.result(binding)
  end
end

class DefaultView < View
  def self.template
    __dir__ + '/fixtures/template.erb'
  end
end

class CustomAssetsPathView < View
end

class CustomAssetsPrefix < View
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

class CompilerView < View
  def self.template
    __dir__ + '/fixtures/compiler-template.erb'
  end
end

class MissingAssetSourceView < View
  def self.template
    __dir__ + '/fixtures/missing-asset-source.erb'
  end
end
