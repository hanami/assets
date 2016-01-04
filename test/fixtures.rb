require 'erb'
require 'sass'
require 'coffee_script'
require 'lotus/assets/es6'
require 'lotus/view'
require 'tilt/erb'

module View
  def self.included(base)
    base.class_eval do
      include Lotus::Assets::Helpers
      extend  ClassMethods
    end
  end

  module ClassMethods
    def template
      __dir__ + '/fixtures/template.erb'
    end
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

class DefaultView
  include View

  def self.template
    __dir__ + '/fixtures/template.erb'
  end
end

class CustomAssetsPathView
  include View
end

class CustomAssetsPrefix
  include View
end

class RenderMultipleAssets
  include View

  def self.template
    __dir__ + '/fixtures/multi-template.erb'
  end
end

class AbsoluteUrlsView
  include View

  def self.template
    __dir__ + '/fixtures/absolute-urls-template.erb'
  end
end

class CompilerView
  include View

  def self.template
    __dir__ + '/fixtures/compiler-template.erb'
  end
end

class MissingAssetSourceView
  include View

  def self.template
    __dir__ + '/fixtures/missing-asset-source.erb'
  end
end

class UnknownAssetEngineView
  include View

  def self.template
    __dir__ + '/fixtures/unknown-asset-engine.erb'
  end
end

class UnchangedCompilerView
  include View

  def self.template
    __dir__ + '/fixtures/unchanged-asset.erb'
  end
end

class CssCompilerView
  include View

  def self.template
    __dir__ + '/fixtures/compile-css.erb'
  end
end

class HiddenAssetCompilerView
  include View

  def self.template
    __dir__ + '/fixtures/hidden-asset.erb'
  end
end

class ImageHelperView
  include Lotus::View
  include Lotus::Assets::Helpers
end

class CustomJavascriptCompressor
  def compress(file)
  end
end

class CustomStylesheetCompressor
  def compress(file)
  end
end
