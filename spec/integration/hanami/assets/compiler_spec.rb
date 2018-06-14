require 'tilt/sass'
require 'tilt/coffee'
require 'hanami/assets/compiler'

describe 'Compiler' do
  before do
    require 'hanami/compass'
    fixtures = __dir__ + "/../../../support/fixtures"
    TMP.rmtree if TMP.exist?
    TMP.mkdir

    Hanami::Assets.configure do
      compile          true
      root             fixtures
      public_directory TMP.join('public')

      sources << [
        'javascripts',
        Pathname.new(fixtures).join('stylesheets'),
        TMP
      ]
    end

    @config = Hanami::Assets.configuration
  end

  after do
    @config.reset!
  end

  it 'copies javascript asset from source to destination' do
    Hanami::Assets::Compiler.compile(@config, 'greet.js')

    target = @config.public_directory.join('assets', 'greet.js')
    expect(target.read).to include %(alert("Hello!");)
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'copies javascript source map from source to destination' do
    Hanami::Assets::Compiler.compile(@config, 'precompiled.min.map')

    target = @config.public_directory.join('assets', 'precompiled.min.map')
    expect(target.read).to match %(//source map of precompiled.min)
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'copies asset from nested source to destination' do
    Hanami::Assets::Compiler.compile(@config, 'bootstrap.js')

    target = @config.public_directory.join('assets', 'bootstrap.js')
    expect(target.read).to match %(// Bootstrap)
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'copies nested asset from nested source to destination' do
    Hanami::Assets::Compiler.compile(@config, 'bootstrap/helper.js')

    target = @config.public_directory.join('assets', 'bootstrap', 'helper.js')
    expect(target.read).to match %(var helper = {})
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'compiles coffeescript asset' do
    Hanami::Assets::Compiler.compile(@config, 'hello.js')

    target = @config.public_directory.join('assets', 'hello.js')
    expect(target.read).to include %(alert("Hello, World!");)
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'compiles es6 asset' do
    Hanami::Assets::Compiler.compile(@config, 'person.js')

    target = @config.public_directory.join('assets', 'person.js')
    expect(target.read).to include %(function Person(firstName, lastName))
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'compiles babel asset' do
    Hanami::Assets::Compiler.compile(@config, 'country.js')

    target = @config.public_directory.join('assets', 'country.js')
    expect(target.read).to include %(function Country(name))
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'compiles jsx asset' do
    Hanami::Assets::Compiler.compile(@config, 'react-component.js')

    target = @config.public_directory.join('assets', 'react-component.js')
    expect(target.read).to include %(React.createElement(MyComponent, { someProperty: true });)
    expect(target.stat.mode.to_s(8)).to eq('100644')
  end

  it 'compiles sass asset' do
    Hanami::Assets::Compiler.compile(@config, 'compile-sass.css')

    target  = @config.public_directory.join('assets', 'compile-sass.css')
    content = target.read
    expect(content).to match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #333; }\n)
    expect(content).to match %(p {\n  white-space: pre;)
  end

  it 'compiles sass asset if a direct dependency has changed' do
    dependency = TestFile.new(path: '_background.scss') do
      write '$background-color: green'
    end

    Hanami::Assets::Compiler.compile(@config, 'sass-dependencies.css')

    target  = @config.public_directory.join('assets', 'sass-dependencies.css')
    content = target.read
    expect(content).to match %(body {\n  background-color: green; }\n)

    dependency.touch('$background-color: blue') do
      Hanami::Assets::Compiler.compile(@config, 'sass-dependencies.css')
      content = target.read
      expect(content).to match %(body {\n  background-color: blue; }\n)
    end
  end

  if CI.enabled?
    it 'compiles sass asset if a transitive dependency has changed'
  else
    it 'compiles sass asset if a transitive dependency has changed' do
      dependency = TestFile.new(path: '_grid.scss') do
        write '$framework-padding: 0'
      end

      Hanami::Assets::Compiler.compile(@config, 'sass-transitive-dependencies.css')

      target  = @config.public_directory.join('assets', 'sass-transitive-dependencies.css')
      content = target.read
      expect(content).to match %(body {\n  padding: 0; }\n)

      dependency.touch('$framework-padding: 1') do
        Hanami::Assets::Compiler.compile(@config, 'sass-transitive-dependencies.css')
        content = target.read
        expect(content).to match %(body {\n  padding: 1; }\n)
      end
    end
  end

  it 'compiles sass asset if a dependency is added' do
    asset_name  = "#{SecureRandom.uuid}.css"
    asset       = TestFile.new(path: "#{asset_name}.sass") do
      write "body\n  margin: 0"
    end

    Hanami::Assets::Compiler.compile(@config, asset_name)

    target  = @config.public_directory.join('assets', asset_name)
    content = target.read
    expect(content).to match %(body {\n  margin: 0; }\n)

    dependency_name = SecureRandom.uuid
    _               = TestFile.new(path: "_#{dependency_name}.sass") do
      write "html\n  padding: 0"
    end

    asset.touch("@import #{dependency_name}\n\nbody\n  margin: 0") do
      Hanami::Assets::Compiler.compile(@config, asset_name)
      content = target.read
      expect(content).to match %(html {\n  padding: 0; }\n\nbody {\n  margin: 0; }\n)
    end
  end

  it 'compiles sass asset if a dependency is removed' do
    dependency_name = SecureRandom.uuid
    _               = TestFile.new(path: "_#{dependency_name}.sass") do
      write "html\n  padding: 0"
    end

    asset_name  = "#{SecureRandom.uuid}.css"
    asset       = TestFile.new(path: "#{asset_name}.sass") do
      write "@import #{dependency_name}\n\nbody\n  margin: 0"
    end

    Hanami::Assets::Compiler.compile(@config, asset_name)

    target  = @config.public_directory.join('assets', asset_name)
    content = target.read
    expect(content).to match %(html {\n  padding: 0; }\n\nbody {\n  margin: 0; }\n)

    asset.touch("body\n  margin: 0") do
      Hanami::Assets::Compiler.compile(@config, asset_name)
      content = target.read
      expect(content).to match %(body {\n  margin: 0; }\n)
    end
  end

  it 'compiles scss asset' do
    Hanami::Assets::Compiler.compile(@config, 'compile-scss.css')

    target = @config.public_directory.join('assets', 'compile-scss.css')
    expect(target.read).to match %(body {\n  font: 100% Helvetica, sans-serif;\n  color: #fff; }\n)
  end

  it 'uses defined sass cache directory' do
    directory = Pathname.new(Dir.pwd).join('tmp', 'sass-cache')
    directory.rmtree if directory.exist?

    Hanami::Assets::Compiler.compile(@config, 'compile-sass.css')

    expect(directory.exist?).to eq(true)
  end

  it 'compiles scss asset if direct dependency has changed' do
    dependency = TestFile.new(path: '_background.scss') do
      write 'body { background-color: purple; }'
    end

    Hanami::Assets::Compiler.compile(@config, 'scss-dependencies.css')

    target  = @config.public_directory.join('assets', 'scss-dependencies.css')
    content = target.read
    expect(content).to match %(body {\n  background-color: purple; }\n)

    dependency.touch('body { background-color: turquoise; }') do
      Hanami::Assets::Compiler.compile(@config, 'scss-dependencies.css')
      content = target.read
      expect(content).to match %(body {\n  background-color: turquoise; }\n)
    end
  end

  if CI.enabled?
    it 'compiles scss asset if transitive dependency has changed'
  else
    it 'compiles scss asset if transitive dependency has changed' do
      dependency = TestFile.new(path: '_grid.scss') do
        write 'body { padding: 0; }'
      end

      Hanami::Assets::Compiler.compile(@config, 'scss-transitive-dependencies.css')

      target  = @config.public_directory.join('assets', 'scss-transitive-dependencies.css')
      content = target.read
      expect(content).to match %(body {\n  padding: 0; }\n)

      dependency.touch('body { padding: 1; }') do
        Hanami::Assets::Compiler.compile(@config, 'scss-transitive-dependencies.css')
        content = target.read
        expect(content).to match %(body {\n  padding: 1; }\n)
      end
    end
  end

  it 'copies unknown asset' do
    Hanami::Assets::Compiler.compile(@config, 'style.foobar')

    target  = @config.public_directory.join('assets', 'style.foobar')
    content = target.read
    expect(content).to eq("This is a foobar file.\n")
  end

  it 'copies unknown asset in folder with a dot in it' do
    Hanami::Assets::Compiler.compile(@config, 'other_style.foobar')

    target  = @config.public_directory.join('assets', 'other_style.foobar')
    content = target.read
    expect(content).to eq("This is a foobar file.\n")
  end

  it "won't compile/copy if the source hasn't changed" do
    Hanami::Assets::Compiler.compile(@config, 'unchanged.js')

    compiled    = @config.public_directory.join('assets', 'unchanged.js')
    content     = compiled.read
    modified_at = compiled.mtime

    expect(content).to include %(alert("Still the same");)

    sleep 1

    Hanami::Assets::Compiler.compile(@config, 'unchanged.js')
    compiled = @config.public_directory.join('assets', 'unchanged.js')

    expect(compiled.read).to include %(alert("Still the same");)
    expect(compiled.mtime.to_i).to eq(modified_at.to_i)
  end

  it 'truncates files when copying from source to destination' do
    source = @config.root.join('javascripts', 'truncate.js')

    begin
      source.delete if source.exist?

      content = "alert('A reasonably long, very very long message.');"

      File.open(source, File::WRONLY | File::CREAT) do |file|
        file.write content
      end

      Hanami::Assets::Compiler.compile(@config, 'truncate.js')

      compiled = @config.public_directory.join('assets', 'truncate.js')
      expect(compiled.read).to eq(content)

      sleep 1

      content = "alert('A short one');"
      File.open(source, File::WRONLY | File::TRUNC | File::CREAT) do |file|
        file.write content
      end

      Hanami::Assets::Compiler.compile(@config, 'truncate.js')

      compiled = @config.public_directory.join('assets', 'truncate.js')
      expect(compiled.read).to eq(content)
    ensure
      source.delete if source.exist?
    end
  end

  it 'raises an error in case of missing source' do
    sources = @config.sources.map(&:to_s).join(', ')
    expect do
      Hanami::Assets::Compiler.compile(@config, 'missing.js')
    end.to raise_error(Hanami::Assets::MissingAsset,
                       "Missing asset: `missing.js' (sources: #{sources})")
  end

  it 'raises an error in case of unknown compiler engine' do
    expect do
      Hanami::Assets::Compiler.compile(@config, 'ouch.js')
    end.to raise_error(Hanami::Assets::UnknownAssetEngine,
                       "No asset engine registered for `ouch.js.unknown'")
  end

  it 'ignores hidden files beginning with a dot' do
    expect do
      Hanami::Assets::Compiler.compile(@config, 'hidden.css')
    end.to raise_error(Hanami::Assets::MissingAsset)
  end
end
