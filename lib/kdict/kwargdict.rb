# Creates a dictionary of generic, keyword-argument models.  Allows user to 
# validate a keyword and value against the models added to the dictionary.
#
# Be sure to check out {KwargTypes} for a better understanding of what kind of
# models can be built and added to the dictionary.

class KwargDict < Hash

   include KwargTypes

  # @example Instantiating
  #   my_dict = KwargDict.new
  def initialize
    super
  end

  # @see KwargModel
  # Adds a new keyword-KwargModel to self.
  # @param kword The name of the kword.
  # @param type_struct_prc Collectively the *typedef*, *struct*, and optional *prc*.
  # @param type AKA the *typedef*, a symbolic form of anyone of the included methods from {KwargTypes}
  # @param struct The *typedef* format is dependent upon the model's *typedef*.  Be sure to refer to those {KwargTypes} to set *structs* appropriately.
  # @param prc Optional.  A Proc that's meant to add to the specificity of *struct*.  Not all *typedefs* accept Procs.
  # @return {KwargModel.new(type, struct, prc)}
  # @example Adding a KwargModel to the KwargDict instance:
  #   my_dict[:example] = :arrayof, Integer
  #   my_dict[:proc_example] = :formof, [Float, Float], Proc.new { |n| n > 2.5 }
  #   p my_dict[:example].splay #=> [:arrayof, Integer]
  #   p my_dict[:proc_example].splay #=> [:formof, [Float, Float], <Proc:0x000055b98848a6d8@kwargdict.rb:20>] 
  def []=(kword, type_struct_prc)
    type, struct, prc = type_struct_prc
    typedef?(type)
    super(kword, KwargModel.new(type, struct, prc))
  end

  # Can add multiple KwargModels in the form of arrays. Remember that *prc* is optional.
  # @param kwargmodel_list A collection of arrays each in the form [*kword*, *typedef*, *struct*, *prc*].
  # @return {KwargModel.new(type, struct, prc)}
  # @see #[]=
  # @example Adding a KwargModel:
  #   my_dict.add([:one, :typeof, String], [:two, :anyof, ['this', 'that']])
  #   p my_dict[:one].splay #=> [:typeof, String]
  #   p my_dict[:two].splay #=> [:anyof, ['this', 'that']] 
  def add(*kwargmodel_list)
    kwargmodel_list.each do |kword, type, struct, prc|
      self[kword] = type, struct, prc
    end
  end

  # Checks a kword and arg passed to it against the list of KwargModels added to
  # self.  Returns false if the kword doesn't exist or if the arg passed in fails
  # validation.  If the KwargModel has a Proc, the proc call will also have to 
  # evaluate to true and does not replace or override the *struct*.
  # @param kword The keyword whose *struct* you wish to check arg against.
  # @param arg The argument, expression, etc., that you wish check against the  *struct*.
  # @return [Boolean]
  # @example Adding a KwargModel and Checking User Input Against It:
  #   my_dict[:label] = :typeof, String
  #   my_dict[:rgba] = :formof, [Numeric]*4, Proc.new { |n| n.ibetween(0, 1) }
  #   my_dict.check(:label, 'Labels Are Fun!') #=> true
  #   my_dict.check(:label, 45) #=> false
  #   my_dict.check(:rgba, [0.5, 1, 0.25, 1]) #=> true
  #   my_dict.check(:rgba, [0.5, 1, 0.25, 11.5]) #=> false
  def check(kword, arg)
    return false if !self.has_key?(kword)
    valid?(arg, *self[kword].splay)
  end

  private def typedef?(type)
    if !@@typedefs.include?(type)
      raise "type must be a type in KwargTypes"
    end
  end

end
