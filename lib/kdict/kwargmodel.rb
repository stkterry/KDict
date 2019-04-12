# A convenient class for storing a unique Keyword-Argument Model

class KwargModel

  attr_reader :type, :struct, :prc 
  
  #@!attribute [r] type
  # @return [typedef]
  # Returns the typdef of the Model.

  #@!attribute [r] struct
  # Returns the structure of the typedef.

  #@!attribute [r] prc
  # @return [Proc]
  # Returns a unique Proc if it exists, otherwise nil.
  
  # @param type [Symbol] the typedef of the instance. It can be any one of the {KwargTypes typedefs}
  # @param struct the structure of the typedef.
  # @param prc an optional Proc that modifies the 'specificity' of struct
  def initialize(type, struct, prc=nil)
    @type = type
    @struct = struct
    @prc = prc if prc
  end

  # Returns the attributes of the instance as an array.
  # @return [[type, struct, prc]] if prc exists.
  # @return [[type, struct]] if prc is nil.
  #
  #@example
  #  km1 = KwargModel.new(:typeof, Float)
  #  km2 = KwargModel.new(:typeof, Float, Proc.new{true})
  #  km1.splay #=> [:typeof, Float]
  #  km2.splay #=> [:typeof, Float, @prc=#<Proc:0x000055c85d7671b0@kwargmodel.rb:20>]
  def splay
    @prc ? [@type, @struct, @prc] : [@type, @struct]
  end

end
