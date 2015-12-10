require 'test_helper'
require __dir__ + '/../fixtures/bookshelf/config/environment'

describe "Lotus::View integration" do
  before do
    # FIXME delete this
    dest.rmtree if dest.exist?
    dest.mkpath

    frameworks = [Web::Assets, Admin::Assets]
    frameworks.each do |framework|
      framework.configure do
        digest false
      end
    end
  end

  # FIXME delete this
  let(:dest) { TMP.join('bookshelf', 'public') }

  it "renders assets from the root path" do
    rendered = Web::Views::Books::Show.render(format: :html)
    rendered.must_include %(<script src="/assets/jquery.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/assets/application.js" type="text/javascript"></script>)
  end

  it "renders assets from a nested path" do
    rendered = Admin::Views::Users::Index.render(format: :html)
    rendered.must_include %(<script src="/assets/admin/zepto.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/assets/admin/application.js" type="text/javascript"></script>)
  end
end
