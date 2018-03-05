require 'digest'
require 'open3'

describe 'Precompile' do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath
  end

  let(:dest)   { TMP }
  let(:target) { dest.join('assets') }

  let(:vendor_files) { %w[robots.txt].map { |file| dest.join(file) } }

  describe 'standalone framework' do
    let(:dest) { TMP.join('standalone', 'public') }

    let(:assets) do
      ['users.js']
    end

    let(:environment) { "#{__dir__}/../../../support/fixtures/standalone/config/environment.rb" }

    it 'precompiles assets' do
      expect_successful_command environment
      expect_successful_output(assets)
    end

    describe 'when already precompiled ' do
      it 'cleans up the destination directory before to precompile' do
        2.times do
          expect_successful_command environment
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        expect(duplicated_manifests.count).to eq(0)
        expect(dest.join(target).exist?).to eq(true)
      end
    end

    describe 'when public directory or public/assets contains some files' do
      it 'keeps this files' do
        expect_successful_command environment
        vendor_files.each { |file| FileUtils.touch file }
        expect_successful_command environment

        vendor_files.each { |f| expect(f.exist?).to eq(true) }
      end

      it "doesn't creates a fingerprinted version" do
        vendor_files.each { |file| FileUtils.touch file }
        expect_successful_command environment

        vendor_files.each do |f|
          fingerprinted_versions = Dir[dest.join("#{f.basename(f.extname)}-*#{f.extname}").to_s]
          expect(fingerprinted_versions).to be_empty
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
       'metrics/dashboard.js',
       'style/style.css']
    end

    let(:environment) { "#{__dir__}/../../../support/fixtures/bookshelf/config/environment.rb" }

    it 'precompiles assets' do
      expect_successful_command environment
      expect_successful_output(assets)
    end

    describe 'when already precompiled ' do
      it 'cleans up the destination directory before to precompile' do
        2.times do
          expect_successful_command environment
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        expect(duplicated_manifests.count).to eq(0)
        expect(dest.join(target).exist?).to eq(true)
      end
    end

    describe 'when public directory or public/assets contains some files' do
      it 'keeps this files' do
        expect_successful_command environment
        vendor_files.each { |file| FileUtils.touch file }
        expect_successful_command environment

        vendor_files.each { |f| expect(f.exist?).to eq(true) }
      end

      it "doesn't creates a fingerprinted version" do
        vendor_files.each { |file| FileUtils.touch file }
        expect_successful_command environment

        vendor_files.each do |f|
          fingerprinted_versions = Dir[dest.join("#{f.basename(f.extname)}-*#{f.extname}").to_s]
          expect(fingerprinted_versions).to be_empty
        end
      end
    end
  end

  describe "when 'config' is omitted" do
    it 'raises error and exit' do
      expect_failing_command '', 'You must specify a configuration file'
    end
  end

  describe "when 'config' points to a non-existing file" do
    it 'raises error and exit' do
      expect_failing_command '--config=path/to/missing.rb', 'Cannot find configuration file: path/to/missing.rb'
    end
  end

  private

  def expect_successful_command(configuration_path)
    expect(system("bundle exec bin/hanami-assets --config=#{configuration_path}")).to eq(true)

    # This is useful for debug
    #
    # load configuration_path
    # Hanami::Assets.deploy
  end

  def expect_successful_output(expected) # rubocop:disable Metrics/AbcSize
    expected.each do |asset|
      result = target.join(asset)
      expect(result).to be_exist

      checksum = Digest::MD5.file(result)
      filename = ::File.basename(asset, '.*')
      ext = ::File.extname(asset)
      directory = Pathname.new(::File.dirname(asset))
      expect(target.join(directory, "#{filename}-#{checksum}#{ext}")).to be_exist
    end
  end

  def expect_failing_command(arguments, error)
    cmd = "bundle exec bin/hanami-assets #{arguments}"

    Open3.popen3(cmd) do |_, _, stderr, _|
      expect(stderr.read).to include(error)
    end
  end
end
