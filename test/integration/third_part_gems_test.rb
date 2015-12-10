require 'test_helper'
require __dir__ + '/../fixtures/bookshelf/config/environment'

describe "Third part gems integration" do
  before do
    # FIXME delete this
    dest.rmtree if dest.exist?
    dest.mkpath

    load __dir__ + '/../fixtures/lotus-emberjs/lib/lotus/emberjs.rb'
  end

  # FIXME delete this
  let(:dest) { TMP.join('bookshelf', 'public') }

  it "renders assets from a third part gem" do
    rendered = Metrics::Views::Dashboard::Index.render(format: :html)
    rendered.must_include %(<script src="/assets/metrics/ember.js" type="text/javascript"></script>)
    rendered.must_include %(<script src="/assets/metrics/dashboard.js" type="text/javascript"></script>)

#     dest.join('assets', 'metrics', 'ember.js').must_be :exist?
#     dest.join('assets', 'metrics', 'dashboard.js').must_be :exist?
  end
end
