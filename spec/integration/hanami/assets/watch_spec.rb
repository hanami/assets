# frozen_string_literal: true

require "hanami/assets/watcher"
require "fileutils"

RSpec.describe "Hanami Assets: Watch" do
  subject do
    Hanami::Assets::Watcher.new(configuration: configuration)
  end

  let(:sources) { Sources.path("watch") }
  let(:destination) { Destination.create }

  let(:configuration) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  it "watches assets" do
    subject.call

    touch("index.js")
    sleep 0.5
    assert_file("index.js")
  end

  private

  def touch(path)
    FileUtils.touch(sources.join(path))
  end

  def assert_file(*path)
    path = destination.join(*path)
    expanded_path = Dir.glob(path).first

    expect(File).to exist(expanded_path || path)
  end
end
