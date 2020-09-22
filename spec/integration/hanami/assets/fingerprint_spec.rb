# frozen_string_literal: true

RSpec.describe "Fingerprint mode" do
  before do
    dest.rmtree if dest.exist?
    dest.mkpath

    load "#{__dir__}/../../../support/fixtures/bookshelf/config/environment.rb"
    Hanami::Assets.deploy

    frameworks = [Web::Assets, Admin::Assets]
    frameworks.each do |framework|
      framework.configure do
        fingerprint true
      end.load!
    end
  end

  let(:dest) { TMP.join("bookshelf", "public") }

  it "uses fingerprinted relative urls" do
    rendered = Web::Views::Books::Show.render(format: :html)
    expect(rendered).to match %(<script src="/assets/jquery-05277a4edea56b7f82a4c1442159e183.js" type="text/javascript"></script>)
    expect(rendered).to match %(<script src="/assets/application-d1829dc353b734e3adc24855693b70f9.js" type="text/javascript"></script>)
  end

  it "raises error when referencing missing asset" do
    expect { Web::Views::Users::Show.render(format: :html) }
      .to raise_error(Hanami::Assets::MissingManifestAssetError,
                      "Can't find asset `/assets/missing.js' in manifest (#{Hanami::Assets.configuration.manifest_path})")
  end
end
