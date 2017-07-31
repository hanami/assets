require __dir__ + "/../../../support/fixtures/bookshelf/config/environment"

describe 'Hanami::View integration' do
  before do
    frameworks = [Web::Assets, Admin::Assets]
    frameworks.each do |framework|
      framework.configure do
        fingerprint false
      end
    end
  end

  it 'renders assets from the root path' do
    rendered = Web::Views::Books::Show.render(format: :html)
    expect(rendered).to include %(<script src="/assets/jquery.js" type="text/javascript"></script>)
    expect(rendered).to include %(<script src="/assets/application.js" type="text/javascript"></script>)
  end

  it 'renders assets from a nested path' do
    rendered = Admin::Views::Users::Index.render(format: :html)
    expect(rendered).to include %(<script src="/assets/admin/zepto.js" type="text/javascript"></script>)
    expect(rendered).to include %(<script src="/assets/admin/application.js" type="text/javascript"></script>)
  end
end
