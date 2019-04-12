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

# DummyClass for checking module ###############
class DMC
    include KwargTypes
end
################################################

describe "KwargTypes" do

  let(:kdict) { KwargDict.new }
  let(:kt) {DMC.new}
  let(:prc) {Proc.new {true}}

  describe "#typeof" do
    it "Should take in an arg and generic datatype, and ensure arg is of that type." do
      expect(kt.typeof("This is a string.", String)).to eq(true)
      expect(kt.typeof("This is a string.", Integer)).to eq(false)
      expect(kt.typeof(47, Integer)).to eq(true)
    end

    it "May optionally take in a Proc that ADDS to the specifity of the method." do
      expect(kt.typeof("This is a string.", String, Proc.new{|n| n.length > 5 })).to eq(true)
      expect(kt.typeof("Nope", String, Proc.new{|n| n.length > 5 })).to eq(false)
      expect(kt.typeof(75, Integer, Proc.new {|n| n % 2 == 0 })).to eq(false)
    end

  end

  describe "#arrayof" do
    it "Should check that the arg(an array) contains only elements of the given generic datatype" do
      expect(kt.arrayof(['1', '2', '3'], String)).to eq(true)
      expect(kt.arrayof(['1', '2', 3], String)).to eq(false)
      expect(kt.arrayof([1,2.0,3], Numeric)).to eq(true)
      expect(kt.arrayof([1,2.0,'3'], Numeric)).to eq(false)
    end

    it "May optionally take in a Proc that ADDS to the specifity of the method." do
      expect(kt.arrayof(['1', '2', '3'], String, Proc.new{|n| n.length == 1})).to eq(true)
      expect(kt.arrayof(['11', '22', '33'], String, Proc.new{|n| n.length == 1})).to eq(false)
      expect(kt.arrayof([1,2.0,3], Numeric, Proc.new{|n| n > 0})).to eq(true)
    end

  end

  describe "#anyof" do
    it "Should check that arg is any one of the values in struct (an array)." do
      expect(kt.anyof('2', ['1', '2', '3'])).to eq(true)
      expect(kt.anyof('4', ['1', '2', '3'])).to eq(false)
      expect(kt.anyof([1,2], [[4], [11, 'blue'], [1,2]])).to eq(true)
      expect(kt.anyof([2], [[4], [11, 'blue'], [1,2]])).to eq(false)
    end

    it "May NOT take in an optional Proc.  Should raise error if one is included." do
      expect{kt.anyof('2', ['1', '2', '3'])}.to_not raise_error
      expect{kt.anyof('2', ['1', '2', '3'], prc)}.to raise_error
    end

  end


  describe "#anyNof" do
    it "Should check that the given arg either matches a specific datatype given in " \
      "struct(an array) else any other specific value in the struct." do
        expect(kt.anyNof('1', [Float, '1', '2', '3'])).to eq(true)
        expect(kt.anyNof(1.0, [Float, '1', '2', '3'])).to eq(true)
        expect(kt.anyNof('4', [Float, '1', '2', '3'])).to eq(false)
        expect(kt.anyNof(45, [Float, '1', '2', '3'])).to eq(false)
        end

    it "May optionally take in a Proc that ADDS to the specifity of the method BUT "\
      "only operates on generic types specified in the struct's array." do
        expect(kt.anyNof('1', [Float, '1', '2', '3'], prc)).to eq(true)
        expect(kt.anyNof(1.0, [Float, '1', '2', '3'], Proc.new{|n| n > 0 })).to eq(true)
        expect(kt.anyNof('4', [Float, '1', '2', '3'], Proc.new{|n| n > 0 })).to eq(false)
    end

  end

  describe "#formof" do
    it "Should check that arg matches the form of struct" do
      expect(kt.formof([1.0, 2], [Float, Integer])).to eq(true)
      expect(kt.formof([1.0, 2.0], [Float, Integer])).to eq(false)
    end

    it "May be given an optional block that must also evaluate to true for each element in arg." do
      tprc = Proc.new { |ele| ele >= 0 && ele <= 1 }
      expect(kt.formof([1.0, 0.9], [Numeric, Numeric], tprc)).to eq(true)
      expect(kt.formof([1.0, 1.2], [Numeric, Numeric], tprc)).to eq(false)
    end
  end

  describe "#kwargsof" do
    
    it "Should receive a hash as an arg and a KwargsDict as a struct." do
      expect(kt).to receive(:kwargsof).with(an_instance_of(Hash), an_instance_of(KwargDict))
      kt.kwargsof({numerictest:3.5}, KwargDict.new)
    end

    it "Should return false if a given kword in arg is not in struct." do
      kdict[:numerictest] = :typeof, Numeric
      kdict[:stringtest] = :typeof, String
      kdict[:arraytest] = :arrayof, Integer
      expect(kt.kwargsof({a:1}, kdict)).to eq(false)
      expect(kt.kwargsof({stringtest:1}, kdict)).to eq(false)
    end

    it "Should return true if the given kword in arg is in the struct AND it's value "\
        "matches the type(s) referenced in struct." do
      kdict[:numerictest] = :typeof, Numeric
      kdict[:stringtest] = :typeof, String
      kdict[:arraytest] = :arrayof, Integer
      expect(kt.kwargsof({numerictest:1.2}, kdict)).to eq(true)
      expect(kt.kwargsof({arraytest:[1, 2, 3]}, kdict)).to eq(true)
    end

    it "Should NOT receive a Proc and should raise an error if so." do
      kdict[:numerictest] = :typeof, Numeric
      kdict[:stringtest] = :typeof, String
      kdict[:arraytest] = :arrayof, Integer
      expect{kt.kwargsof({a:1}, kdict, prc)}.to raise_error
    end

  end

  describe "#adv_formof" do
    it "Should return false if arg is not an array." do
      expect(kt.adv_formof('NotAnArray', [nil])).to eq(false)
    end

    it "Should return false if arg and struct are not of the same length." do
      expect(kt.adv_formof(['An', 'Array'], 
        [[:typeof, String], [:typeof, String], [:arrayof, Integer]])).to eq(false)
    end

    it "arg should be an array, each element corresponding to a unique type, struct, "\
      "and possibly call in an array of arrays in the main struct." do
      expect(kt.adv_formof(['An', 'Array', [1,2,3]], 
        [[:typeof, String], [:typeof, String, prc], [:arrayof, Integer]])).to eq(true)
    end

    it "Each sub_struct may include an optional, unique Proc." do
      expect{kt.adv_formof(['An', 'Array'], 
        [[:typeof, String, prc], [:typeof, String, Proc.new{|n| n.include?(A)}], [:arrayof, Integer]])}.to_not raise_error
    end
  end

  describe "#and_kwargsof" do

    it "Should return true if arg is not an array but its sole element meets criteria "\
      "of the first sub_struct in struct." do
      expect(kt.and_kwargsof(1, [[:typeof,Numeric],[:typeof,Numeric],[:kwargsof, kdict]])).to eq(true)
    end

    it "Should return true if each element in arg meets its sub_struct criteria but a "\
      "kwargsof element is not present in arg." do
      expect(kt.and_kwargsof([1, 2], [[:typeof,Numeric],[:typeof,Numeric],[:kwargsof, kdict]])).to eq(true)
    end

    it "If arg is shorter than struct but contains a hash, should check each element, AND hash corresponds to kwargsof in struct." do
      kdict[:a] = :typeof, Numeric
      kdict[:b] = :typeof, String
      kdict[:c] = :arrayof, Integer
      expect(kt.and_kwargsof([1, {a:1, b:'2'}], [[:typeof,Numeric],[:typeof,Numeric],[:kwargsof, kdict]])).to eq(true)
    end

  end

end
