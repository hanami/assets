require 'hanami/assets/sass/engine'

RSpec.describe Hanami::Assets::Sass::Engine do
  let(:template) { double('template') }
  let(:source) { ::SassC::Engine }
  let(:source_engine) { instance_double(::SassC::Engine) }

  it 'wraps the source Sass renderer' do
    expect(source).to receive(:new).with(template, {})
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

  describe '#dependencies' do
    it 'forwards the call to the wrapped source' do
      allow(source).to receive(:new).and_return(source_engine)
      our_engine = described_class.new(template)

      expect(source_engine).to receive(:dependencies).and_return([])
      our_engine.dependencies
    end
  end
end
