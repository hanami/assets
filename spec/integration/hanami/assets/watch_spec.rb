# frozen_string_literal: true

require "hanami/assets/watcher"
require "fileutils"

RSpec.describe "Hanami Assets: Watch" do
  subject do
    Hanami::Assets::Watcher.new(config: config)
  end

  let(:app) { App.create(source) }
  let(:source) { Sources.path("myapp") }

  let(:config) do
    srcs = source
    dest = app

    Hanami::Assets::Config.new do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  xit "watches assets" do
    Dir.chdir(app) do
      subject.call

      assert_file("public/assets/index.js")
      contents = read_file("public/assets/index.js")
      expect(contents).to include("console.log(\"Hello World\")")

      # Change file
      write_file("assets/index.js", "console.log(\"Hello Watch\")")
      sleep 0.5
      expect(contents).to include("console.log(\"Hello Watch\")")
    end
  end

  private

  def touch(path)
    FileUtils.touch(sources.join(path))
  end

  def assert_file(*path, content: nil)
    actual_path = expand_path(*path)

    expect(File).to exist(actual_path), "expected `#{actual_path.inspect}' to exist"

    if content
      expect(File.read(actual_path)).to include(content)
    end
  end

  def read_file(*path)
    actual_path = expand_path(*path)

    File.read(actual_path)
  end

  def write_file(*path, content)
    actual_path = expand_path(*path)

    File.write(actual_path, content)
  end

  def expand_path(*path)
    path = app.join(*path)
    expanded_path = Dir.glob(path).first

    (expanded_path || path).to_s
  end
end
