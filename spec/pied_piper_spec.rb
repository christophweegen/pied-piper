RSpec.shared_examples 'a piper' do
  let(:piper) { described_class }

  it 'has a version number' do
    expect(PiedPiper::VERSION).not_to be nil
  end

  describe 'can be initialized' do
    it 'with obj' do
      result = piper.call('test')
      expect(result.class).to be(PiedPiper)
    end

    it 'with block' do
      result = piper.call { 'test' }
      expect(result.class).to be(PiedPiper)
    end

    context 'with proc as' do
      it 'proc' do
        p = proc { 'test' }
        result = piper.call(p)
        expect(result.class).to be(PiedPiper)
      end

      it 'lambda' do
        p = -> { 'test' }
        result = piper.call p
        expect(result.class).to be(PiedPiper)
      end

      it 'stabby lambda' do
        p = -> { 'test' }
        result = piper.call p
        expect(result.class).to be(PiedPiper)
      end
    end
  end
end

RSpec.describe PiedPiper.method(:new) do
  it_behaves_like 'a piper'
end

RSpec.describe method(:pipe) do
  it_behaves_like 'a piper'
end
