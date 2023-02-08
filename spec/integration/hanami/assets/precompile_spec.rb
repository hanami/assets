# frozen_string_literal: true

require "hanami/assets/precompiler"

RSpec.describe "Hanami Assets: Precompile" do
  subject do
    Hanami::Assets::Precompiler.new(configuration: configuration)
  end

  let(:sources) { Sources.path("hello_world") }
  let(:destination) { Destination.create }

  let(:configuration) do
    srcs = sources
    dest = destination

    Hanami::Assets::Configuration.new do |config|
      config.sources = srcs
      config.destination = dest
    end
  end

  it "precompiles assets" do
    subject.call

    assert_file("manifest.json")

    assert_file("index-*.js")
    assert_file("index-*.js.map")
    assert_file("index-*.css")
    assert_file("index-*.css.map")
  end

  context "assets minification" do
    let(:sources) { Sources.path("minification") }

    it "minifies assets" do
      content = "(()=>{var t=r=>r<=1?r:t(r-1)+t(r-2);})();"
      subject.call

      assert_file("index-*.js", content: content)
    end
  end

  context "with multiple entry points" do
    let(:sources) { Sources.path("entry_points") }

    it "precompiles multiple bundles" do
      subject.call

      assert_file("manifest.json")

      directories = ["admin", File.join("main", "dashboard"), File.join("main", "login")]

      directories.each do |dir|
        assert_file(dir, "index-*.js")
        assert_file(dir, "index-*.js.map")
      end
    end
  end

  context "with precompilation error" do
    let(:sources) { Sources.path("syntax_error") }

    it "expects to raise error" do
      expect { subject.call }.to raise_error(Hanami::Assets::PrecompileError)
    end
  end

  private

  def assert_file(*path, content: nil)
    path = destination.join(*path)
    expanded_path = Dir.glob(path).first
    actual_path = (expanded_path || path).to_s

    expect(File).to exist(actual_path), "expected `#{actual_path.inspect}' to exist"

    if content
      expect(File.read(actual_path)).to include(content)
    end
  end
end
