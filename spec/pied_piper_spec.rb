require 'pied_piper/kernel'

RSpec.describe PiedPiper do
  include PiedPiper::Kernel

  it 'has a version number' do
    expect(PiedPiper::VERSION).not_to be nil
  end

  describe "String pipes" do
    it "can pipe and terminate" do
      p = piper("foo")

      a = p | :upcase | p.end
      b = p | :upcase | PiedPiper::EndOfPipe
      c = p | :upcase | p_end

      expect(a).to eq("FOO")
      expect(b).to eq("FOO")
      expect(c).to eq("FOO")
    end
  end

  describe "Array pipes" do
    it "with one parameters" do
      p = piper("Pied")
      concat = [:concat, " Piper"]
      result = p | concat | p.end

      expect(result).to eq("Pied Piper")
    end

    it "with multiple parameters" do
      p = piper("Pied Piper")
      concat = [:concat, " of", " Hamelin"]
      result = p | concat | p.end

      expect(result).to eq("Pied Piper of Hamelin")
    end

    it "with block" do
      p = piper("Pied Piper")

      map_double = [:map, ->(str) { str * 2 }]
      result = p | :split | map_double | :join | p_end
      # => "PiedPiedPiperPiper"

      expect(result).to eq("PiedPiedPiperPiper")
    end

    it "with parameters and block" do
      p = piper("Pied Piper")

      map_double_array = [:each_with_object, [], ->(str, array) { array << [str * 2] }]
      result = p | :split | map_double_array | p_end

      expect(result).to eq([["PiedPied"], ["PiperPiper"]])
    end
  end

  describe "with Proc" do
    it "with one parameter" do
      p = piper("Pied")

      concat = ->(x) { x + " Piper" }

      result = p | concat | p.end

      expect(result).to eq("Pied Piper")
    end
  end
end
