require 'test_helper'
require 'digest'

describe 'Precompile' do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath
  end

  describe "standalone framework" do
    let(:dest) { TMP.join('standalone', 'public', 'assets') }

    let(:assets) do
      ['users.js']
    end

    it "precompiles assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/standalone/config/environment.rb"
      assert_successful_output(assets)
    end
  end

  describe "duplicated frameworks" do
    let(:dest) { TMP.join('bookshelf', 'public', 'assets') }

    let(:assets) do
      ['jquery.js',
       'ember.js',              # this is a duplicate
       'ember-source.js',       # this is a duplicate
       'application.js',
       'admin/ember.js',        # this is a duplicate
       'admin/ember-source.js', # this is a duplicate
       'admin/zepto.js',
       'admin/application.js',
       'metrics/ember.js',
       'metrics/ember-source.js',
       'metrics/dashboard.js']
    end

    it "precompiles assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/bookshelf/config/environment.rb"
      assert_successful_output(assets)
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
      result = dest.join(asset)
      result.must_be :exist?

      checksum      = Digest::MD5.file(result)
      filename, ext = ::File.basename(asset, '.*'), ::File.extname(asset)
      directory     = Pathname.new(::File.dirname(asset))
      dest.join(directory, "#{ filename }-#{ checksum }#{ ext }").must_be :exist?
    end
  end
end
