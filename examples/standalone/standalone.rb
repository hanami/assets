require 'erb'
require 'lotus/assets'

Lotus::Assets.configure do
  # configure if not following the convention (folder structure etc..)
end

class TemplateObject
  include Lotus::Assets::Helpers

  def articles
    ['test', 'test1', 'test2']
  end

  def get_binding
    binding
  end
end

template = ERB.new File.new("index.html.erb").read, nil, "%"
p template.result(TemplateObject.new.get_binding)
