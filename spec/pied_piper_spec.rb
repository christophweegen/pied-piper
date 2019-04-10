RSpec.describe PiedPiper do
  let(:piper) { described_class }

  class MyClass
    def self.bangify(string)
      string + '!!!'
    end
  end

  it 'pipes things through' do
    p = PiedPiper.new('h')
    meth = :upcase # pipess through method on given object
    meth_with_params = [:concat, 'el', 'lo'] # methods with arbitrary params
    prc = ->(str) { str + " world" } # objects of Proc class
    meth_obj = MyClass.method(:bangify)
    result = p | meth | meth_with_params | prc | meth_obj | p.end
    expect(result).to eq("Hello world!!!")
  end

  it 'has a version number' do
    expect(PiedPiper::VERSION).not_to be nil
  end

  # describe 'can be initialized' do
  # it 'with obj' do
  # result = piper.call('test')
  # expect(result.class).to be(PiedPiper)
  # end

  # it 'with block' do
  # result = piper.call { 'test' }
  # expect(result.class).to be(PiedPiper)
  # end

  # context 'with proc as' do
  # it 'proc' do
  # p = proc { 'test' }
  # result = piper.call(p)
  # expect(result.class).to be(PiedPiper)
  # end

  # it 'lambda' do
  # p = -> { 'test' }
  # result = piper.call p
  # expect(result.class).to be(PiedPiper)
  # end

  # it 'stabby lambda' do
  # p = -> { 'test' }
  # result = piper.call p
  # expect(result.class).to be(PiedPiper)
  # end
  # end
  # end
end
