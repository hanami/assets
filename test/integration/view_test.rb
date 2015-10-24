require 'test_helper'

describe "Lotus::View integration" do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath
  end

  let(:dest) { TMP.join('bookshelf', 'public') }

  it "renders assets from the root path" do
    rendered = Web::Views::Books::Show.render(format: :html)
    rendered.must_include %(<script src="/assets/jquery.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/assets/application.js" type="text/javascript"></script>)

    dest.join('assets', 'jquery.js').must_be :exist?
    dest.join('assets', 'application.js').must_be :exist?
  end

  it "renders assets from a nested path" do
    rendered = Admin::Views::Users::Index.render(format: :html)
    rendered.must_include %(<script src="/admin/assets/zepto.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/admin/assets/application.js" type="text/javascript"></script>)

    dest.join('assets', 'admin', 'zepto.js').must_be :exist?
    dest.join('assets', 'admin', 'application.js').must_be :exist?
  end
end
