require 'test_helper'
require 'digest'
require 'open3'

describe 'Precompile' do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath
  end

  let(:dest)   { TMP }
  let(:target) { dest.join('assets') }

  let(:vendor_files) { %w(robots.txt).map { |file| dest.join(file) } }

  describe 'standalone framework' do
    let(:dest) { TMP.join('standalone', 'public') }

    let(:assets) do
      ['users.js']
    end

    let(:environment) { "#{__dir__}/../fixtures/standalone/config/environment.rb" }

    it 'precompiles assets' do
      assert_successful_command environment
      assert_successful_output(assets)
    end

    describe 'when already precompiled ' do
      it 'cleans up the destination directory before to precompile' do
        2.times do
          assert_successful_command environment
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        duplicated_manifests.count.must_equal 0
        dest.join(target).exist?.must_equal true
      end
    end

    describe 'when public directory or public/assets contains some files' do
      it 'keeps this files' do
        assert_successful_command environment
        vendor_files.each { |file| FileUtils.touch file }
        assert_successful_command environment

        vendor_files.each { |f| f.exist?.must_equal true }
      end

      it "doesn't creates a digest version" do
        vendor_files.each { |file| FileUtils.touch file }
        assert_successful_command environment

        vendor_files.each do |f|
          digest_versions = Dir[dest.join("#{f.basename(f.extname)}-*#{f.extname}").to_s]
          digest_versions.must_be :empty?
        end
      end
    end
  end

  describe 'duplicated frameworks' do
    let(:dest) { TMP.join('bookshelf', 'public') }

    let(:assets) do
      ['jquery.js',
       'bookshelf.jpg',
       'ember.js',              # this is a duplicate
       'ember.min.js',          # this is a duplicate
       'ember-source.js',       # this is a duplicate
       'application.js',
       'admin/ember.js',        # this is a duplicate
       'admin/ember.min.js',    # this is a duplicate
       'admin/ember-source.js', # this is a duplicate
       'admin/zepto.js',
       'admin/application.js',
       'metrics/ember.js',
       'metrics/ember.min.js',
       'metrics/ember-source.js',
       'metrics/dashboard.js']
    end

    let(:environment) { "#{__dir__}/../fixtures/bookshelf/config/environment.rb" }

    it 'precompiles assets' do
      assert_successful_command environment
      assert_successful_output(assets)
    end

    describe 'when already precompiled ' do
      it 'cleans up the destination directory before to precompile' do
        2.times do
          assert_successful_command environment
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        duplicated_manifests.count.must_equal 0
        dest.join(target).exist?.must_equal true
      end
    end

    describe 'when public directory or public/assets contains some files' do
      it 'keeps this files' do
        assert_successful_command environment
        vendor_files.each { |file| FileUtils.touch file }
        assert_successful_command environment

        vendor_files.each { |f| f.exist?.must_equal true }
      end

      it "doesn't creates a digest version" do
        vendor_files.each { |file| FileUtils.touch file }
        assert_successful_command environment

        vendor_files.each do |f|
          digest_versions = Dir[dest.join("#{f.basename(f.extname)}-*#{f.extname}").to_s]
          digest_versions.must_be :empty?
        end
      end
    end
  end

  describe "when 'config' is omitted" do
    it 'raises error and exit' do
      assert_failing_command '', 'You must specify a configuration file'
    end
  end

  describe "when 'config' points to a non-existing file" do
    it 'raises error and exit' do
      assert_failing_command '--config=path/to/missing.rb', 'Cannot find configuration file: path/to/missing.rb'
    end
  end

  private

  def assert_successful_command(configuration_path)
    assert system("bundle exec bin/hanami-assets --config=#{configuration_path}"),
           'Expected bin/hanami-assets to be successful'

    # This is useful for debug
    #
    # load configuration_path
    # Hanami::Assets.deploy
  end

  def assert_successful_output(expected)
    expected.each do |asset|
      result = target.join(asset)
      result.must_be :exist?

      checksum = Digest::MD5.file(result)
      filename = ::File.basename(asset, '.*')
      ext = ::File.extname(asset)
      directory = Pathname.new(::File.dirname(asset))
      target.join(directory, "#{filename}-#{checksum}#{ext}").must_be :exist?
    end
  end

  def assert_failing_command(arguments, error)
    cmd = "bundle exec bin/hanami-assets #{arguments}"

    Open3.popen3(cmd) do |_, _, stderr, _|
      stderr.read.must_include error
    end
  end
end
