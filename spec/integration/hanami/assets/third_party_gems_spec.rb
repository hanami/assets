# frozen_string_literal: true

require "#{__dir__}/../../../support/fixtures/bookshelf/config/environment"

RSpec.describe "Third part gems integration" do
  before do
    load "#{__dir__}/../../../support/fixtures/hanami-emberjs/lib/hanami/emberjs.rb"
  end

  it "renders assets from a third part gem" do
    rendered = Metrics::Views::Dashboard::Index.render(format: :html)
    expect(rendered).to include %(<script src="/assets/metrics/ember.js" type="text/javascript"></script>)
    expect(rendered).to include %(<script src="/assets/metrics/dashboard.js" type="text/javascript"></script>)
  end
end
