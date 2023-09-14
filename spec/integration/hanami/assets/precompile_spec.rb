# frozen_string_literal: true

require "json"
require "fileutils"
require "hanami/assets/precompiler"

RSpec.describe "Hanami Assets: Precompile" do
  subject do
    Hanami::Assets::Precompiler.new(config: config)
  end

  let(:app) { App.create(sources_path) }
  let(:sources_path) { Test::Sources.path("myapp") }
  let(:config_kwargs) { {sources: sources_path, destination: app}.compact }

  let(:config) { Hanami::Assets::Config.new(**config_kwargs) }

  it "precompiles assets" do
    FileUtils.ln_sf(File.join(Dir.pwd, "node_modules"), app.join("node_modules"))

    Dir.chdir(app) do
      subject.call

      assert_file("public/assets.json")

      assert_file("public/assets/app-*.js")
      assert_file("public/assets/app-*.js.map")

      manifest = JSON.parse(read_file("public/assets.json"))
      expect(manifest).to eq({
                               "admin/app.js" => {"url" => "/assets/admin/app-2SHWWMX7.js"},
                               "app.css" => {"url" => "/assets/app-7OZQGGFO.css"},
                               "app.js" => {"url" => "/assets/app-CLORMJFW.js"}
                             })
    end
  end

  context "with precompilation error" do
    let(:sources_path) { Test::Sources.path("syntax_error") }

    it "expects to raise error" do
      pending "awaiting the syntax_errors/ test fixtures to be properly added"

      expect { subject.call }.to raise_error(Hanami::Assets::PrecompileError)
    end
  end

  private

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

  def expand_path(*path)
    path = app.join(*path)
    expanded_path = Dir.glob(path).first

    (expanded_path || path).to_s
  end
end
