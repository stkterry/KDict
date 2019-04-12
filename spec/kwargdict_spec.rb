# The code below suppresses stdout while rspec runs.
#################################################################
RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
#################################################################

describe "KwargDict" do

  let (:kd) do
    KwargDict.new
  end

  it "Should inherit Hash class." do
    kd
    expect(kd).to be_a(Hash)
  end

  it "Should include KwargTypes." do
  end

  describe "#[]=" do
    it "self should receive kword and assign to it a KwargModel with type, struct, and optional prc." do
      kd[:test] = :typeof, Integer, Proc.new {"Pillow Talk"}
      expect(kd[:test]).to be_a(KwargModel)
      expect(kd[:test].type).to eq(:typeof)
      expect(kd[:test].struct).to eq(Integer)
      expect(kd[:test].prc).to be_a(Proc)
    end

    it "Should check that the type variable is a symbol that corresponds to a type method in the KwargTypes module." do
      expect{ kd[:test] = :typeoff, Integer}.to raise_error
      expect{ kd[:test] = :typeof, Integer}.to_not raise_error
    end

  end

  describe "#check" do
    it "Should accept a kword and an arg." do
      kd.check(:typeof, 3)
    end

    it "Should return false if kword is not a key of self." do
      kd[:test] = :typeof, Integer
      expect(kd.check(:tes, 3)).to eq(false)
    end

    it "Should use the kword to call to self's corresponding KwargModel and validate "\
      "arg against KwargModel's type and struct by using #valid? from the KwargTypes module." do
        kd[:test] = :typeof, Integer
        kd[:test2] = :arrayof, Float
        expect(kd.check(:test, 3)).to eq(true)
        expect(kd.check(:test2, [1.0, 2.1, 3.5])).to eq(true)
        expect(kd.check(:test, "3")).to eq(false)
        expect(kd.check(:test2, [1, 2, 3.5])).to eq(false)
      end

  end

end