require 'test_helper'
require 'lotus/assets/bundler'
require 'etc'
require 'json'

describe Lotus::Assets::Bundler do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath

    FileUtils.copy_entry(source, dest.join('assets'))
    config.destination.must_equal(dest) # better safe than sorry ;-)

    Lotus::Assets::Bundler.new(config).run
  end

  let(:config) do
    Lotus::Assets::Configuration.new.tap do |c|
      c.destination dest
    end
  end

  let(:dest)   { TMP.join('deploy', 'public') }
  let(:source) { __dir__ + '/fixtures/deploy/public/assets' }

  it "compresses javascripts" do
    assets(:js).each do |original, current|
      assert_valid_compressed_asset(original, current)
    end
  end

  it "compresses stylesheets" do
    assets(:css).each do |original, current|
      assert_valid_compressed_asset(original, current)
    end
  end

  it "copies other assets" do
    assets(:png).each do |original, current|
      assert_same_asset(original, current)
      assert_valid_asset(         current)
    end
  end

  it "generates manifest" do
    manifest = dest.join('assets.json')
    manifest.must_be :exist?

    assert_owner(      manifest)
    assert_permissions(manifest)

    actual   = JSON.load(manifest.read)
    expected = JSON.load(File.read(__dir__ + '/fixtures/deploy/assets.json'))

    actual.size.must_equal expected.size
    expected.each do |original, current|
      actual[original].must_equal current
    end
  end

  private

  def assets(type)
    Dir.glob("#{ dest }/**/*.#{ type }").each_with_object({}) do |current, result|
      next unless checksum(current)
      result[original_for(current)] = current
    end
  end

  def original_for(asset)
    filename = ::File.basename(asset).sub(/\-[\w]{32}+(\.(.*))\z/, '\1')
    Dir.glob("#{ source }/**/#{ filename }").first
  end

  def assert_valid_compressed_asset(original, current)
    assert_compressed(original, current)
    assert_valid_asset(         current)
  end

  def assert_valid_asset(current)
    assert_checksum(   current)
    assert_owner(      current)
    assert_permissions(current)
  end

  def assert_compressed(original, current)
    original_size = ::File.size(original)
    current_size  = ::File.size(current)

    assert current_size < original_size,
      "Expected #{ current } (#{ current_size }b) to be smaller than #{ original } (#{ original_size }b)"

    compressed = compress(original)
    actual     = ::File.read(current)

    # remove this line in case YUI-Compressor won't be used for production code anymore.
    actual.must_equal(compressed)

    delta = -100.0 + (( actual.size * 100 ) / compressed.size.to_f)
    assert delta < 20,
      "Expected algorithm to have a 20% maximum of degradation, if compared with YUI-Compressor, got: #{ delta }"
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
      "Expected #{ current } to be the same asset of #{ original }"
  end

  def checksum(file)
    file.scan(/[\w]{32}/).first
  end

  def compress(file)
    case File.extname(file)
    when ".js"  then YUI::JavaScriptCompressor.new(munge: true)
    when ".css" then YUI::CssCompressor.new
    end.compress(::File.read(file))
  end
end
