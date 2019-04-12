# KDict - A Kwarg Dictionary

KDict allows you to quickly create powerful Keyword-Argument Dictionaries.  Each
entry can be used to validate a user's input against it, and is built from a
generic type defintion (*typedef*) and a unique structure (*struct*).

With the included *typedefs* users can create simple to complex validaters in
just a single line of code.

Examples avaible here in the README don't offer up the full scope of usefulness,
so take the time to look at the example documentation in the full docs page.

View full docs at: https://stkterry.github.io/KDict/

View source code at: https://github.com/stkterry/KDict/

{file:doc/Example1.md}

***

### KwargDict
This class defines a new, empty dictionary which can be filled with KwargModels.
The class inherits Hash.
#### Initialization:
```ruby
kdict = KwargDict.new
```

#### Adding Models to the Dictionary:
Each entry in the dictionary gets a name and the appropriate parameters used to
construct a KwargModel.
As an example the following definitions might be used in an app where the user is
allowed to modify a label, it's fontsize, it's color, and x_data for a graph.

```ruby
kdict[:label] = :typeof, String
kdict[:fontsize] = :typeof, Integer
kdict[:rgb] = :formof, [Integer]*3, Proc.new { |n| 0 <= n && n <= 255 }
kdict[:x_data] = :arrayof, Float

# Or if you prefer a single command
kdict.add([:one, :typeof, Bool], [:two, :kwargsof, anotherKwargModel],
  [:three, :anyof, ['this', 'or', 'that']]) # ... etc.
```
#### KwargModel Structure
Each entry in the dictionary is defined by its name and by two or three parameters.

  * **type** - The model's generic type
  * **struct** - The model's structure/definition
  * **prc** - An optional Proc that increases specificity of the model's defintion.
    * *not all typedefs allow for an optional Proc*

#### Checking Input Against the Dictionary:
In the user's main code, one need only provide a single line to test input

```ruby
kdict.check(:label, "Is This A Good Label?") # => true
kdict.check(:lable, "A mispelled kword") # => false
kdict.check(:fontsize, 16) # => true
kdict.check(:fontsize, '16') # => false
kdict.check(:rgb, [125, 0, 223]) # => true
kdict.check(:rgb, [256, 0, 192]) # => false
kdict.check(:rgb, [125, 0]) # => false
kdict.check(:x_data, [1.3, 2.5, 4.0, 11.1]) # => true
#... etc.
```
***

### Where Is This Useful?
Any application that might have a large number of optional parameters across
several different methods, such as graphing libs and user-databases.

#### Example Implementation Snippet:
A user made want to format strings and pass them on to an interpreter or other application.

```ruby
class MyFigure
  include TextKwargs # <- A predefined KwargDict (text_dict) would be included in this module.
  attr_reader :my_params
  def initialize(title)
    @title = title
    @my_params = {}
  end

  def set_some_params(*kwords_vals)
    kwords_vals.each_slice(2) do |kword, val|
      @my_params[kword] = val if text_dict.check(kword, val)
    end
  end
end

fig = MyFigure.new("It Came From Outer Space!")
fig.set_some_params(:fontsize, 11, :fontfamily, 'sans', :bold, true, :fontname, 'Georiga')
```
How users treat validated or failed parameters from here is left to the imagination.

***

### Anatomy of a KwargModel:
#### Typedef and Struct

Each *typedef* is actually a method built to handle a particular kind of *struct*, while
each *struct* is what makes an instance of KwargModel unique.  Some *typedefs* will
only allow for a specific set of *struct* values while others are more flexible.  There are just
eight *typedef* methods, though you can easily make your own.

#### ***:typeof*** 
Your *struct* contains a singular value of exactly one datatype.

* ***structs*** - Some of Ruby's built-in types plus *Bool*, an added datatype for 
  true/false collectively.  Acceptable *struct* arguments then, are: **Numeric, Float, Integer, Bool, String, Symbol**
* Can accept a Proc that must also return true for successful validation

```ruby
my_dict[:example] = :typeof, Bool
my_dict.check(:example, false) # => true
my_dict.check(:example, true) # => true

my_dict[:proc_example] = :typeof, Float, Proc.new { |n| n > 5.3 }
my_dict.check(:proc_example, 2.1) # => false
my_dict.check(:proc_example, 5.4) # => true
my_dict.check(:proc_example, 6) # => false ... note that 6 > 5.3 but 6 is not datatype Float
```
***

#### ***:arrayof***
Your *struct* contains an array of any length but contains only one datatype.

* ***structs*** - Again some of Ruby's built-in types plus Bool: **Numeric, Float, Integer, Bool, String, Symbol**
* Multi-dimensional arrays will be treated as flattened and all values will still
be checked against the given *struct*
* Can accept a Proc that must return true for ALL values in the array.

```ruby
my_dict[:example] = :arrayof, Strings
my_dict.check(:example, ['This', 'will', 'return', 'true']) # => true
my_dict.check(:example, ['This', 'is', 'false', 4.7]) # => false

my_dict[:proc_example] = :arrayof, Strings, Proc.new { |s| s.length > 2 }
my_dict.check(:proc_example, ['This', 'will', 'return', 'true']) # => true
my_dict.check(:proc_example, ['This', 'is', 'still', 'false']) # => false
```
***

#### ***:anyof***
Your *struct* contains a singular element that can be found in an array.

* ***structs*** - An array of any mix of things you'd like, EXCEPT other instances of KwargModels or KwargDicts.
* Will not accept a Proc and must not contain generic datatype symbols.

```ruby
my_dict[:example] = :anyof, ['xx-small', 'x-small', 'large', 3.2]
my_dict.check(:example, 'x-small') # => true
my_dict.check(:example, 3.2) # => true
my_dict.check(:example, 'xx-large') # => false
```
***

#### ***:anyNof***
Your *struct* contains an element AND specific datatypes in an array.

* ***structs*** - An array of any mixed things you'd like plus generic datatype keywords **Numeric, Float, Integer, Bool, String, Symbol**
* Can accept a Proc that will only operate on a given value if it's identified by a generic datatype in *struct* after a check for explicit existence in the array

```ruby
my_dict[:example] = :anyNof, [Integer, 'red', 'blue', 'magenta']
my_dict.check(:example, 'red') # => true
my_dict.check(:example, 34) # => true

my_dict[:proc_example] = :anyNof, [Float, 'green', 3.1], Proc.new { |n| n > 5 }
my_dict.check(:proc_example, 'green') # => true
my_dict.check(:proc_example, 6.1) # => true
my_dict.check(:proc_example, 3.1) # => true
# Again note that :anyNof's Proc is operating only on values NOT explicitly listed in the array.
```
***

#### ***:formof***
Your *struct* contains an array of exact length, you expect each element to be contained in a 
specific order and be a generic datatype

* ***structs*** - An array of set length containing generic datatype keywords **Numeric, Float, Integer, Bool, String, Symbol**, in 
a specific order.  Will return false if user input appears out of order with respect
to the *struct*.
* Can accept a Proc that must return true for ALL values in the array.

```ruby
my_dict[:example] = :formof, [Bool, Float, String]
my_dict.check(:example, [false, 3.1, "Holly Dolly"]) # => true
my_dict.check(:example, [false, 3.1]) # => false
my_dict.check(:example, ["Holly Dolly", 3.1, false]) # => false

my_dict[:proc_example] = :formof, [Integer, Float, Float], Proc.new { |n| 1 < n && n < 3 }
my_dict.check(:proc_example, [2, 1.1, 1.2]) # => true
my_dict.check(:proc_example, [1.1, 2, 1.4]) # => false
```

***

#### ***:kwargsof***
Your *struct* contains a hash that corresponds to another KwargDict

* ***structs*** - Can only be another KwargDict instance.
* Will not accept a Proc
* Input hash need not contain every *kword* from the nested KwargDict to return true
* Will return true only if every key-arg pair in input hash is valid in nested KwargDict

```ruby
another_dict.add([:one, :typeof, Float], [:two, :arrayof, String], [:three, :typeof, Bool],
  [:and, :anyof, ['partridge', 'in', 'a', 'pear', 'tree']])

my_dict[:example] = :kwargsof, another_dict
my_dict.check(:example, {one:3.1, three:false, and:'in'}) # => true
my_dict.check(:example, {two:['this', 'works'], four:'without this'}) # => false
my_dict.check(:example, {two:['see?']}) # => true
```
***

#### ***:adv_formof***
Your *struct* contains an array of exact length, each of whom's elements has its own subset of
*typedef*, *struct*, and possibly *prc*

* ***structs*** - Must be an array of exact length, each element of which is a sub array
containing *typedef*, *struct*, and an optional *prc*, in that order.  Can accept
**:typeof, :arrayof, :anyof, :anyNof, :formof**, and **:adv_formof**.
* Will NOT accept *:kwargsof* or *:and_kwargsof*.
* Will return false if user input appears out of order with respect to the *struct*.
* Will not accept a Proc outside of a sub *typedef*.  Each element in *struct* may
have its own unique Proc, however, if allowed for that *typedef*.

```ruby
my_dict[:example] = :adv_formof, [[:typeof, Float], [:arrayof, Integer]]
my_dict.check(:example, [3.1, [1, 2, 3, 4, 5]]) # => true
my_dict.check(:example, [3.1, ['1', '2', '3']]) # => false

my_dict[:proc_example] = :adv_formof, [[:typeof, String, Proc.new { |s| s.length > 5 }],
  [:formof, [Float]*3 , Proc.new { |n| 0 <= n && n <= 1 }]]
my_dict.check(:proc_example, ["Longer", [0.25, 0.5, 1.0]]) # => true
my_dict.check(:proc_example, ["Longer", [-0.25, 0.5, -1.0]]) # => false
my_dict.check(:proc_example, ["Short", [0.25, 0.5, 1.0]]) # => false
```

***

#### ***:and_kwargsof***
Your *struct* is structured like *:adv_formof* but the last element MUST be a *:kwargsof* *typedef*

* ***structs*** - MUST be an array in the form of *:adv_formof*, but the last sub *typedef* MUST
be *:kwargsof*
* Will return true if given a single value that returns true from the first sub *typedef* in the array.
* Will return true if given an array of values in the order they appear in *struct*, without skipping one, and each
returns true from its respective sub *typedef*
* Will return true if the previous statement is true but the given array also includes a hash that corresponds
to the last sub *typedef* in the *struct*, which again must always be *:kwargsof*.
* Will return false if only a hash is present, even if the hash elements are all valid to its
nested KwargDict
* Each sub *typedef* may receive a Proc if allowed for that *typedef*

```ruby
another_dict.add([:one, :typeof, Float], [:two, :arrayof, String])
my_dict[:example] = :and_kwargsof, [[:typeof, String], [:typeof, Bool], [:kwargsof, another_dict]]

my_dict.check(:example, 'It works!') # => true
my_dict.check(:example, ['And this.']) # => true
my_dict.check(:example, ['This too.', true]) # => true
my_dict.check(:example, ['As does this.', false, {two:['Super!']}]) # => true
my_dict.check(:example, ['Even this works.', {two:['Yep.'], one:3.1}]) # => true

my_dict.check(:example, true) # => false | Skips the first element of :example
my_dict.check(:example, [true, 'It broke!']) # => false | Elements appear out of order
my_dict.check(:example, {one:'Nope'}) # => false | Contains only the hash
```

### ToDo:

* Add more examples.

* Modify the typedefs *:kwargsof* and *:and_kwargsof* to return a mapping of true
  and false values.  Write a method #granular_check into KwargDict to return
  those arrays of Bools and re-write #check to return a singular Bool based on whether
  any Bool in the array from #granular_check is false.

* Concerning the above, may re-rewrite those typedefs to return hashes of Bools,
  which may make it even easier for the user to decide what to do with the returned
  validation data.

* The RSPEC files do not yet check every detail of the KwargTypes as they should.

* Add another module that check's most aspects of a definition itself.
  In other words, checking that the *struct* a user wishes to assign to a
  definition in a KwargDict fits within the boundaries set by it's associated
  *typedef*.  No assigning the datatype keyword 'Array' to a *:typeof* model,
  for instance.

* Better documentation?

* Build a method into KwargDict that allows the user to easily merge specific
  entries from different dictionaries.
