require 'erb'

module Rendering
  def self.template
    raise NotImplementedError
  end

  def initialize
    @template = File.read(self.class.template)
  end

  def render
    ERB.new(@template).result(binding)
  end
end

class DefaultView
  include Lotus::Assets::Helpers
  include Rendering

  def self.template
    __dir__ + '/fixtures/template.erb'
  end
end

class CustomAssetsPathView
  include Lotus::Assets::Helpers
  include Rendering

  def self.template
    __dir__ + '/fixtures/template.erb'
  end

  private
  def _javascript_prefix
    'custom-assets-path'
  end

  def _stylesheet_prefix
    'custom-assets-path-for-css'
  end
end
