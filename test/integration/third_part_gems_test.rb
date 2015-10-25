require 'test_helper'

describe "Third part gems integration" do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath

    require 'lotus/emberjs'
  end

  let(:dest) { TMP.join('bookshelf', 'public') }

  it "renders assets from a third part gem" do
    rendered = Metrics::Views::Dashboard::Index.render(format: :html)
    rendered.must_include %(<script src="/assets/metrics/ember.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/assets/metrics/dashboard.js" type="text/javascript"></script>)

    dest.join('assets', 'metrics', 'ember.js').must_be :exist?
    dest.join('assets', 'metrics', 'dashboard.js').must_be :exist?
  end
end
