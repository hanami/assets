require 'hanami/assets/less/engine'

RSpec.describe Hanami::Assets::Less::Engine do
  let(:template) { double('template') }
  let(:source) { Tilt }
  let(:source_engine) { double('source engine') }

  it 'wraps the source Less renderer' do
    expect(source).to receive(:new).with(template, nil, {})
    described_class.new(template)
  end

  describe '#render' do
    it 'forwards the call to the wrapped source' do
      allow(source).to receive(:new).and_return(source_engine)
      our_engine = described_class.new(template)

      expect(source_engine).to receive(:render)
      our_engine.render
    end
  end
end
