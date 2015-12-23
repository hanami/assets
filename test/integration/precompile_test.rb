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

  describe "standalone framework" do
    let(:dest) { TMP.join('standalone', 'public') }

    let(:assets) do
      ['users.js',
       'application.css']
    end

    it "precompiles assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/standalone/config/environment.rb"
      assert_successful_output(assets)
    end

    describe "when already precompiled " do
      it "cleans up the destination directory before to precompile" do
        2.times do
          assert_successful_command "#{ __dir__ }/../fixtures/standalone/config/environment.rb"
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        duplicated_manifests.count.must_equal 0
      end
    end
  end

  describe "duplicated frameworks" do
    let(:dest) { TMP.join('bookshelf', 'public') }

    let(:assets) do
      ['jquery.js',
       'bookshelf.jpg',
       'ember.js',              # this is a duplicate
       'ember.min.js',          # this is a duplicate
       'ember-source.js',       # this is a duplicate
       'application.js',
       'application.css',
       'admin/ember.js',        # this is a duplicate
       'admin/ember.min.js',    # this is a duplicate
       'admin/ember-source.js', # this is a duplicate
       'admin/zepto.js',
       'admin/application.js',
       'admin/application.css',
       'metrics/ember.js',
       'metrics/ember.min.js',
       'metrics/ember-source.js',
       'metrics/application.css',
       'metrics/dashboard.js']
    end

    it "precompiles assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/bookshelf/config/environment.rb"
      assert_successful_output(assets)
    end

    it "uses correct rendering context for assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/bookshelf/config/environment.rb"

      web_application_stylesheet     = dest.join('assets', 'application.css')
      web_application_stylesheet.read.must_include %(/assets/bookshelf.jpg)

      admin_application_stylesheet   = dest.join('assets', 'admin', 'application.css')
      admin_application_stylesheet.read.must_include %(/assets/admin/logo.png)

      metrics_application_stylesheet = dest.join('assets', 'metrics', 'application.css')
      metrics_application_stylesheet.read.must_include %(/assets/metrics/logo.png)
    end

    describe "when already precompiled " do
      it "cleans up the destination directory before to precompile" do
        2.times do
          assert_successful_command "#{ __dir__ }/../fixtures/bookshelf/config/environment.rb"
        end

        duplicated_manifests = Dir[dest.join('assets-*.json').to_s]
        duplicated_manifests.count.must_equal 0
      end
    end
  end

  describe "when 'config' is omitted" do
    it 'raises error and exit' do
      assert_failing_command "", "You must specify a configuration file (ArgumentError)"
    end
  end

  describe "when 'config' points to a non-existing file" do
    it 'raises error and exit' do
      assert_failing_command "--config=path/to/missing.rb", "Cannot find configuration file: path/to/missing.rb (ArgumentError)"
    end
  end

  private

  def assert_successful_command(configuration_path)
    assert system("bundle exec bin/lotus-assets --config=#{ configuration_path }"),
      "Expected bin/lotus-assets to be successful"

     # This is useful for debug
     #
     # load configuration_path
     # Lotus::Assets.deploy
  end

  def assert_successful_output(expected)
    expected.each do |asset|
      result = target.join(asset)
      result.must_be :exist?

      checksum      = Digest::MD5.file(result)
      filename, ext = ::File.basename(asset, '.*'), ::File.extname(asset)
      directory     = Pathname.new(::File.dirname(asset))
      target.join(directory, "#{ filename }-#{ checksum }#{ ext }").must_be :exist?
    end
  end

  def assert_failing_command(arguments, error)
    cmd = "bundle exec bin/lotus-assets #{ arguments }"

    Open3.popen3(cmd) do |_, _, stderr, _|
      stderr.read.must_include error
    end
  end
end
