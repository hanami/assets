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
    expect(config.public_directory).to eq(dest) # better safe than sorry ;-)
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
      let(:source) { __dir__ + "/../../../support/fixtures/deploy/public/assets" }

      it 'compresses javascripts' do
        run!

        assets(:js).each do |original, current|
          expect_valid_compressed_asset(compressor, original, current)
        end
      end

      it 'compresses stylesheets' do
        run!

        assets(:css).each do |original, current|
          expect_valid_compressed_asset(compressor, original, current)
        end
      end

      it 'copies other assets' do
        run!

        assets(:png).each do |original, current|
          expect_same_asset(original, current)
          expect_valid_asset(current)
        end
      end

      it 'generates manifest' do
        run!

        manifest = dest.join('assets.json')
        expect(manifest).to be_exist

        expect_owner(manifest)
        expect_permissions(manifest)

        actual   = JSON.parse(manifest.read)
        expected = JSON.parse(File.read(__dir__ + "/../../../support/fixtures/deploy/assets.json"))

        expect(actual.size).to eq(expected.size)
        expected.each do |original, current|
          extname  = File.extname(original)
          basename = File.join(File.dirname(original), File.basename(original, extname))

          expected_target = /\A#{basename}\-[[:alnum:]]{32}#{extname}\z/
          expected_sri    = [/\Asha256\-[[[:alnum:]][[:punct:]][[:graph:]]]{43}\=\z/]

          expect(current.fetch("target")).to match(expected_target)
          expected_sri.each_with_index do |value, i|
            expect(current.fetch("sri")[i]).to match(value)
          end
        end
      end

      it 'ensures intermediate directories to be created' do
        dest.rmtree if dest.exist?

        run!

        manifest = dest.join('assets.json')
        expect(manifest).to be_exist
      end

      if compressor == :yui
        describe 'in case of error' do
          let(:dest)   { TMP.join('broken', 'public') }
          let(:source) { __dir__ + '/../../../support/fixtures/broken/public/assets' }

          it 'prints the name of the asset that caused the problem' do
            expect { run! }.to output(/Skipping compression of:/).to_stderr
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

  def expect_valid_compressed_asset(compressor, original, current)
    expect_compressed(compressor, original, current)
    expect_valid_asset(current)
  end

  def expect_valid_asset(current)
    expect_checksum    current
    expect_owner       current
    expect_permissions current
  end

  def expect_compressed(_compressor, original, current)
    original_size = ::File.size(original)
    current_size  = ::File.size(current)

    expect(current_size).to be <= original_size

    # compressed = compress(compressor, original)
    # actual     = ::File.read(current)

    # remove this line in case YUI-Compressor won't be used for production code anymore.
    # actual.must_equal(compressed)

    # delta = -100.0 + (( actual.size * 100 ) / compressed.size.to_f)
    # assert delta < 20,
    #   "Expected algorithm to have a 20% maximum of degradation, if compared with YUI-Compressor, got: #{ delta }"
  end

  def expect_checksum(file)
    checksum = Digest::MD5.file(file).to_s
    actual   = checksum(file)

    expect(actual).to eq(checksum)
  end

  def expect_owner(file)
    stat = ::File::Stat.new(file)
    user = Etc.getpwuid(Process.uid)

    expect(user.uid).to eq(stat.uid)
    expect(user.gid).to eq(stat.gid)
  end

  def expect_permissions(file)
    stat = ::File::Stat.new(file)
    expect(stat.mode.to_s(8)).to eq('100644')
  end

  def expect_same_asset(original, current)
    expect(Digest::MD5.file(original)).to eq(Digest::MD5.file(current))
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
