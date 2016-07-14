require 'test_helper'
require 'hanami/assets/bundler'
require 'hanami/assets/compressors/javascript'
require 'hanami/assets/compressors/stylesheet'
require 'etc'
require 'json'

describe Hanami::Assets::Bundler do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath

    FileUtils.copy_entry(source, dest.join('assets'))
    config.public_directory.must_equal(dest) # better safe than sorry ;-)
  end

  [nil, :builtin, :yui, :uglifier, :closure, :sass].each do |compressor|
    describe (compressor || 'NullCompressor').to_s do # rubocop:disable Lint/ParenthesesAsGroupedExpression
      let(:config) do
        Hanami::Assets::Configuration.new.tap do |c|
          c.public_directory dest
          c.javascript_compressor _javascript_compressor(compressor)
          c.stylesheet_compressor _stylesheet_compressor(compressor)
          c.subresource_integrity true
        end
      end

      let(:dest)   { TMP.join('deploy', 'public') }
      let(:source) { __dir__ + '/fixtures/deploy/public/assets' }

      it 'compresses javascripts' do
        run!

        assets(:js).each do |original, current|
          assert_valid_compressed_asset(compressor, original, current)
        end
      end

      it 'compresses stylesheets' do
        run!

        assets(:css).each do |original, current|
          assert_valid_compressed_asset(compressor, original, current)
        end
      end

      it 'copies other assets' do
        run!

        assets(:png).each do |original, current|
          assert_same_asset(original, current)
          assert_valid_asset(current)
        end
      end

      it 'generates manifest' do
        run!

        manifest = dest.join('assets.json')
        manifest.must_be :exist?

        assert_owner(manifest)
        assert_permissions(manifest)

        actual   = JSON.load(manifest.read)
        expected = JSON.load(File.read(__dir__ + "/fixtures/deploy/assets-#{compressor || 'null'}.json"))

        actual.size.must_equal expected.size
        expected.each do |original, current|
          actual[original].must_equal current
        end
      end

      it 'ensures intermediate directories to be created' do
        dest.rmtree if dest.exist?

        run!

        manifest = dest.join('assets.json')
        manifest.must_be :exist?
      end

      if compressor == :yui
        describe 'in case of error' do
          let(:dest)   { TMP.join('broken', 'public') }
          let(:source) { __dir__ + '/fixtures/broken/public/assets' }

          it 'prints the name of the asset that caused the problem' do
            _, err = capture_subprocess_io { run! }
            err.must_match 'Skipping compression of:'
          end
        end
      end
    end
  end # compressor

  private

  def run!
    Hanami::Assets::Bundler.new(config, []).run
  end

  def assets(type)
    Dir.glob("#{dest}/**/*.#{type}").each_with_object({}) do |current, result|
      next unless checksum(current)
      result[original_for(current)] = current
    end
  end

  def original_for(asset)
    filename = ::File.basename(asset).sub(/\-[\w]{32}+(\.(.*))\z/, '\1')
    Dir.glob("#{source}/**/#{filename}").first
  end

  def assert_valid_compressed_asset(compressor, original, current)
    assert_compressed(compressor, original, current)
    assert_valid_asset(current)
  end

  def assert_valid_asset(current)
    assert_checksum    current
    assert_owner       current
    assert_permissions current
  end

  def assert_compressed(_compressor, original, current)
    original_size = ::File.size(original)
    current_size  = ::File.size(current)

    assert current_size <= original_size,
           "Expected #{current} (#{current_size}b) to be smaller or equal than #{original} (#{original_size}b)"

    # compressed = compress(compressor, original)
    # actual     = ::File.read(current)

    # remove this line in case YUI-Compressor won't be used for production code anymore.
    # actual.must_equal(compressed)

    # delta = -100.0 + (( actual.size * 100 ) / compressed.size.to_f)
    # assert delta < 20,
    #   "Expected algorithm to have a 20% maximum of degradation, if compared with YUI-Compressor, got: #{ delta }"
  end

  def assert_checksum(file)
    checksum = Digest::MD5.file(file).to_s
    actual   = checksum(file)

    actual.must_equal checksum
  end

  def assert_owner(file)
    stat = ::File::Stat.new(file)
    user = Etc.getpwuid(Process.uid)

    user.uid.must_equal stat.uid
    user.gid.must_equal stat.gid
  end

  def assert_permissions(file)
    stat = ::File::Stat.new(file)
    stat.mode.to_s(8).must_equal('100644')
  end

  def assert_same_asset(original, current)
    assert Digest::MD5.file(original) == Digest::MD5.file(current),
           "Expected #{current} to be the same asset of #{original}"
  end

  def checksum(file)
    file.scan(/[\w]{32}/).first
  end

  def compress(compressor, file)
    case File.extname(file)
    when '.js'  then Hanami::Assets::Compressors::Javascript.for(compressor)
    when '.css' then Hanami::Assets::Compressors::Stylesheet.for(compressor)
      # when ".js"  then YUI::JavaScriptCompressor.new(munge: true)
      # when ".css" then YUI::CssCompressor.new
    end.compress(::File.read(file))
  end

  def _javascript_compressor(compressor)
    case compressor
    when :builtin, :yui, :uglifier, :closure
      compressor
    end
  end

  def _stylesheet_compressor(compressor)
    case compressor
    when :builtin, :yui, :sass
      compressor
    end
  end
end
