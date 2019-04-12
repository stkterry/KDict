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

describe "KwargModel" do

  let(:km) do
    type = :typeof
    struct = Integer
    prc = Proc.new{"Hello Dolly."}
    KwargModel.new(type, struct, prc)
  end

  let(:km2) do
    type = :typeof
    struct = Integer
    KwargModel.new(type, struct)
  end

  describe "#initialize" do

    it "Should accept as args: type, struct, and an optional Proc." do
      km
      km2
    end

    it "Should take in a type, struct, and optional prc, and assign them to @type, @struct, and @prc." do
      expect(km.instance_variable_get(:@type)).to eq(:typeof)
      expect(km.instance_variable_get(:@struct)).to eq(Integer)
      expect(km.instance_variable_get(:@prc)).to be_a(Proc)
      expect(km.prc.call).to eq("Hello Dolly.")
    end

    it "@prc should return nil if a value was not given at initialization." do
      expect(km2.instance_variable_get(:@prc)).to eq(nil)
    end

  end

  describe "#splay" do
    it "Should return an array containing @type, @struct, @prc. Should not return a @prc value if it doesn't exist." do
      km_splay = km.splay
      expect(km_splay.length).to eq(3)
      expect(km_splay[0..1]).to eq([:typeof, Integer])
      expect(km_splay[2]).to be_a(Proc)

      km_splay2 = km2.splay
      expect(km_splay2.length).to eq(2)
      expect(km_splay2).to eq([:typeof, Integer])
    end
  end

end