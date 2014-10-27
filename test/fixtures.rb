require 'erb'

class View
  @@template = __dir__ + '/fixtures/template.erb'

  def initialize
    @template = File.read(@@template)
  end

  def render
    ERB.new(@template).result(binding)
  end

  def javascript(file)
    %(<script src="/assets/#{ file }.js" type="text/javascript"></script>)
  end

  def stylesheet(file)
    %(<link href="/assets/#{ file }.css" type="text/css" rel="stylesheet">)
  end
end
