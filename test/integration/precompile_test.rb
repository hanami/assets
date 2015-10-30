require 'test_helper'
require 'digest'

describe 'Precompile' do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath
  end

  let(:target) { dest.join('assets') }

  describe "standalone framework" do
    let(:dest) { TMP.join('standalone', 'public') }

    let(:assets) do
      ['users.js']
    end

    it "precompiles assets" do
      assert_successful_command "#{ __dir__ }/../fixtures/standalone/config/environment.rb"
      assert_successful_output(assets)
    end
  end

  describe "duplicated frameworks" do
    let(:dest) { TMP.join('bookshelf', 'public') }

    let(:assets) do
      ['jquery.js',
       'bookshelf.jpg',
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
      result = target.join(asset)
      result.must_be :exist?

      checksum      = Digest::MD5.file(result)
      filename, ext = ::File.basename(asset, '.*'), ::File.extname(asset)
      directory     = Pathname.new(::File.dirname(asset))
      target.join(directory, "#{ filename }-#{ checksum }#{ ext }").must_be :exist?
    end
  end
end
