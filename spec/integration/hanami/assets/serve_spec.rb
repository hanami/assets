# frozen_string_literal: true

require "rack"
require "rack/builder"
require "rack/test"
require "pathname"
require "fileutils"

RSpec.describe "Hanami Assets: Serve" do
  include Rack::Test::Methods

  before do
    # simulate esbuild watch mode
    FileUtils.cp(sources.join("index.js"), destination)
  end

  let(:app) {
    config = configuration

    Rack::Builder.new do
      map "/assets" do
        run Rack::Files.new(config.destination)
      end

      run ->(_) { [200, {}, ["OK"]] }
    end
  }

  let(:sources) { Sources.path("serve") }
  let(:destination) { Destination.create }

  let(:configuration) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  it "serves assets" do
    get "/assets/index.js"

    expect(last_response).to be_ok

    headers = last_response.headers

    # Ensure Last-Modified respects file system mtime
    # This is useful for browser caching
    last_modified = Date.today.strftime("%a, %d %b %Y") # e.g. Wed, 08 Feb 2023
    expect(headers["Last-Modified"]).to match(last_modified)
    expect(headers["Content-Type"]).to eq("application/javascript")
    expect(headers["Content-Length"]).to eq("22")
  end

  it "returns 404 for not found asset" do
    get "/assets/unknown"

    expect(last_response.status).to be(404)
  end
end
