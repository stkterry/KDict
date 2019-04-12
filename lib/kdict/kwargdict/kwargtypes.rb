# KwargTypes is a collection of generic definitions that are called as parameters
# from {KwargDict}.  Each definition or *typedef* validates a user's input against
# models built in the dictionary. Every *typedef* receives a user's argument and
# an associated *struct*, and checks to see if that argument passes the *struct*'s
# unique conditions. All *typedefs* return Boolean.  Some *typedefs* can receive
# a Proc that further modifies the *struct*'s behavior by adding to (but never overridding)
# its conditions for truthiness.
#
module KwargTypes

  # Used internally.  Gives *typedefs* access to a modified list of generic datatypes.
  @@types = [Numeric, Float, Integer, Hash, Array, Bool, String, Symbol]

  # Used by KwargDict to check against listed definitions before accepting
  # a new KwargModel.
  @@typedefs = [:typeof, :arrayof, :anyof, :anyNof, :formof, :kwargsof,
    :adv_formof, :and_kwargsof]

  #  ====Your *struct* contains a singular value of exactly one datatype.
  #
  # * *structs* - Some of Ruby's built-in types plus *Bool*, an added datatype for 
  #   true/false collectively.  Acceptable *struct* arguments then, are: *Numeric*, *Float*, *Integer*, *Bool*, *String*, *Symbol*
  # * Can accept a Proc that must also return true for successful validation
  # @return [Boolean]
  # @example (Called From a KwargDict instance)
  #  my_dict[:example] = :typeof, Bool
  #  my_dict[:proc_example] = :typeof, Float, Proc.new { |n| n > 5.3 }
  #  my_dict.check(:example, false) # => true
  #  my_dict.check(:proc_example, 2.1) # => false
  def typeof(arg, struct, prc=nil)
    return false if [Hash, Array].any? { |type| arg.is_a?(type) }
    prc ||= Proc.new{true}
    arg.is_a?(struct) && prc.call(arg)
  end

  #  ====Your *struct* contains an array of any length but contain only one datatype.
  #
  # * *structs* - Again some of Ruby's built-in types plus Bool: *Numeric*, *Float*, *Integer*, *Bool*, *String*, *Symbol*
  # * Multi-dimensional arrays will be treated as flattened and all values will still
  #   be checked against the given *struct*
  # * Can accept a Proc that must return true for ALL values in the array.
  # @return [Boolean]
  # @example (Called From a KwargDict instance)
  #   my_dict[:example] = :arrayof, Strings
  #   my_dict[:proc_example] = :arrayof, Strings, Proc.new { |s| s.length > 2 }
  #   my_dict.check(:example, ['This', 'will', 'return', 'true']) # => true
  #   my_dict.check(:proc_example, ['This', 'is', 'still', 'false']) # => false
  def arrayof(arg, struct, prc=nil)
    return false if !arg.is_a?(Array)
    prc ||= Proc.new{true}
    arg.flatten.all? { |ele| ele.is_a?(struct) && prc.call(ele) }
  end

  # ====Your *struct* contains a singular element that can be found in an array.
  #
  # * *structs* - An array of any mix of things you'd like, EXCEPT other instances of KwargModels or KwargDicts.
  # * Will not accept a Proc and must not contain generic datatype symbols.
  # @return [Boolean]
  # @example (Called From a KwargDict instance)
  #  my_dict[:example] = :anyof, ['xx-small', 'x-small', 'large', 3.2]
  #  my_dict.check(:example, 3.2) # => true
  #  my_dict.check(:example, 'xx-large') # => false
  def anyof(arg, struct)
    struct.include?(arg)
  end

  # ====Your *struct* contains an element OR specific datatype in an array.
  #
  # * *structs* - An array of any mixed things you'd like plus generic datatype 
  #   keywords *Numeric*, *Float*, *Integer*, *Bool*, *String*, *Symbol*
  # * Can accept a Proc that will only operate on a given value if it's identified 
  #   by a generic datatype in *struct* after a check for explicit existence in the array
  # @example (Called From a KwargDict instance)
  #   my_dict[:example] = :anyNof, [Integer, 'red', 'blue', 'magenta']
  #   my_dict[:proc_example] = :anyNof, [Float, 'green', 3.1], Proc.new { |n| n > 5 }
  #   my_dict.check(:example, 'red') # => true
  #   my_dict.check(:example, 34) # => true
  #   my_dict.check(:proc_example, 'green') # => true
  #   my_dict.check(:proc_example, 6.1) # => true
  #   my_dict.check(:proc_example, 3.1) # => true
  def anyNof(arg, struct, prc=nil)
    prc ||= Proc.new {true}
    return true if anyof(arg, struct)
    if struct.select { |ele| @@types.include?(ele) }.any? { |type| arg.is_a?(type) && prc.call(arg) }
      return true
    end
    false
  end

  # ====Your *struct* contains an array of exact length, you expect each element to be contained in a specific order and be a generic datatype
  #
  # * *structs* - An array of set length containing generic datatype keywords *Numeric*, 
  #   *Float*, *Integer*, *Bool*, *String*, *Symbol*, in a specific order.  Will 
  #   return false if user input appears out of order with respect to the *struct*.
  # * Can accept a Proc that must return true for ALL values in the array.
  # @example (Called From a KwargDict instance)
  #   my_dict[:example] = :formof, [Bool, Float, String]
  #   my_dict[:proc_example] = :formof, [Integer, Float, Float], Proc.new { |n| 1 < n && n < 3 }
  #   my_dict.check(:example, [false, 3.1, "Holly Dolly"]) # => true
  #   my_dict.check(:example, [false, 3.1]) # => false
  #   my_dict.check(:example, ["Holly Dolly", 3.1, false]) # => false
  #   my_dict.check(:proc_example, [2, 1.1, 1.2]) # => true
  #   my_dict.check(:proc_example, [1.1, 2, 1.4]) # => false
  def formof(arg, struct, prc=nil)
    prc ||= Proc.new {true}
    return false if !arg.is_a?(Array)
    arg.zip(struct).all? { |a,s| a.is_a?(s) && prc.call(a) } ? (return true) : (return false)
  end

  # ====Your *struct* contains a hash that corresponds to another KwargDict
  #
  # * ***structs*** - Can only be another KwargDict instance.
  # * Will not accept a Proc
  # * Input hash need not contain every *kword* from the nested KwargDict to return true
  # * Will return true only if every key-arg pair in input hash is valid in nested KwargDict
  # @example (Called From a KwargDict instance)
  #   another_dict.add([:one, :typeof, Float], [:two, :arrayof, String], [:three, :typeof, Bool],
  #     [:and, :anyof, ['partridge', 'in', 'a', 'pear', 'tree']])
  #   my_dict[:example] = :kwargsof, another_dict
  #   my_dict.check(:example, {one:3.1, three:false, and:'in'}) # => true
  #   my_dict.check(:example, {two:['this', 'works'], four:'without this'}) # => false
  #   my_dict.check(:example, {two:['see?']}) # => true
  def kwargsof(arg, struct)
    return false if !arg.keys.all? { |sub_kword| struct.has_key?(sub_kword) }
    arg.all? { |sub_word, sub_arg| valid?(sub_arg, *struct[sub_word].splay) }
  end

# ====Your *struct* contains an array of exact length, each of whom's elements has its own subset of *typedef*, *struct*, and possibly *prc*
#
# * *structs* - Must be an array of exact length, each element of which is a sub array
#   containing *typedef*, *struct*, and an optional *prc*, in that order.  Can accept
#   *:typeof*, *:arrayof*, *:anyof*, *:anyNof*, *:formof*, and *:adv_formof*.
# * Will NOT accept *:kwargsof* or *:and_kwargsof*.
# * Will return false if user input appears out of order with respect to the *struct*.
# * Will not accept a Proc outside of a sub *typedef*.  Each element in *struct* may
#   have its own unique Proc, however, if allowed for that *typedef*.
# @example (Called From a KwargDict instance)
#   my_dict[:example] = :adv_formof, [[:typeof, Float], [:arrayof, Integer]]
#   my_dict[:proc_example] = :adv_formof, [[:typeof, String, Proc.new { |s| s.length > 5 }],
#     [:formof, [Float]*3 , Proc.new { |n| 0 <= n && n <= 1 }]]
#   my_dict.check(:example, [3.1, [1, 2, 3, 4, 5]]) # => true
#   my_dict.check(:example, [3.1, ['1', '2', '3']]) # => false
#   my_dict.check(:proc_example, ["Longer", [0.25, 0.5, 1.0]]) # => true
#   my_dict.check(:proc_example, ["Longer", [-0.25, 0.5, -1.0]]) # => false
#   my_dict.check(:proc_example, ["Short", [0.25, 0.5, 1.0]]) # => false
  def adv_formof(arg, struct)
    return false if !arg.is_a?(Array) || arg.length != struct.length
    arg.zip(struct).all? { |a, s| valid?(a, *s) }
  end

# ====Your *struct* is structured like *:adv_formof* but the last element MUST be a *:kwargsof* *typedef*
#
# * *structs* - MUST be an array in the form of *:adv_formof*, but the last sub 
#   *typedef* MUST be a *kwargsof*
# * Will return true if given a single value that returns true from the first sub *typedef* in the array.
# * Will return true if given an array of values in the order they appear in *struct*, 
#   without skipping one, and each returns true from its respective sub *typedef*
# * Will return true if the previous statement is true but the given array also
#   includes a hash that corresponds to the last sub *typedef* in the *struct*, 
#   which again must always be *:kwargsof*.
# * Will return false if only a hash is present, even if hash elements are
#   all valid to its nested KwargDict
# * Each sub *typedef* may receive a Proc if allowed for that *typedef*
# @example (Called From a KwargDict instance)
#   another_dict.add([:one, :typeof, Float], [:two, :arrayof, String])
#   my_dict[:example] = :and_kwargsof, [[:typeof, String], [:typeof, Bool], [:kwargsof, another_dict]]
#   my_dict.check(:example, 'It works!') # => true
#   my_dict.check(:example, ['And this.']) # => true
#   my_dict.check(:example, ['This too.', true]) # => true
#   my_dict.check(:example, ['As does this.', false, {two:['Super!']}]) # => true
#   my_dict.check(:example, ['Even this works.', {two:['Yep.'], one:3.1}]) # => true
#   my_dict.check(:example, true) # => false | Skips the first element of :example
#   my_dict.check(:example, [true, 'It broke!']) # => false | Elements appear out of order
#   my_dict.check(:example, {one:'Nope'}) # => false 
  def and_kwargsof(arg, struct)
    return false if arg.is_a?(Hash)
    
    # If only one arg of several are present and it's the first...
    if !arg.is_a?(Array)
      return valid?(arg, *struct[0])
    end 

    if !arg[-1].is_a?(Hash)
      return adv_formof(arg, struct[0...arg.length])
    else
      return false if !adv_formof(arg[0...-1], struct[0...arg.length-1])
      return valid?(arg[-1], *struct[-1])
    end

  end
  
  private def valid?(arg, type, struct, prc=nil)
    prc ? (self.send type, arg, struct, prc) : (self.send type, arg, struct)
  end

end
