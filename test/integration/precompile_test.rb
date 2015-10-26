require 'test_helper'

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
      success = system("bundle exec bin/lotus-assets --config=#{ __dir__ }/../fixtures/standalone/config/environment.rb")
      success.must_equal true

      assets.each do |asset|
        dest.join(asset).must_be :exist?
      end
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
      success = system("bundle exec bin/lotus-assets --config=#{ __dir__ }/../fixtures/bookshelf/config/environment.rb")
      success.must_equal true
      # load __dir__ + '/../fixtures/bookshelf/config/environment.rb'
      # require 'lotus/assets/precompiler'
      # Lotus::Assets::Precompiler.run

      assets.each do |asset|
        dest.join(asset).must_be :exist?
      end
    end
  end
end
