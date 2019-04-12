# A Hilariously Contrieved Though Functional Example
I'll just state outright that this demonstration is merely to show the usefulness
of KDict in a larger example.

Before the code, let's just pretend you're trying to create a database
of rare cars from another planet... in another galaxy, and information available
to you is sparse.  You just want to fill in what you know.  We're going to create
a set of dictionaries and a MyCar class that let's us fill in information.

Along the way there'll be two helper modules, HashPrint. It's irrelevant to the task
at hand but will help your output look like mine, if that at all matters to you.

For simplicity sake, refer back to the {file:README.md} file if
you're lost on what's going on.  It might be useful when looking at how the
dictionaries are built to refer back to the specific *typedef* (AKA {KwargTypes} ) 
on a line-by-line basis to get a feel for what each does.

## Building a CarDict Module
The module will contain a few related KwargDicts just to make it 
easier to split and/or manage the way we use them.  The final dict combines the
former two just to demonstrate that there's a *typedef* for that purpose.

```ruby
module CarDict
  ENGINE = KwargDict.new
  ENGINE.add(
    [:hp, :typeof, Integer, Proc.new { |n| 95 <= n && n <= 800 } ],
    [:liters, :typeof, Float, Proc.new { |n| 1 <= n && n <= 10 }],
    [:max_torque, :typeof, Numeric, Proc.new { |n| n >= 25 }],
    [:turbo, :typeof, Bool])

  CAR_OPTIONS = KwargDict.new
  CAR_OPTIONS.add([:sunroof, :typeof, Bool], 
    [:sport_package, :anyof, ['K1', 'K2', 'K3']],
    [:heated_seats, :typeof, Bool], 
    [:audio_package, :anyof, ['Loud', 'Louder', 'Loudest']])

  CAR_DICT = KwargDict.new
  CAR_DICT.add(
    [:doors, :typeof, Integer, Proc.new{ |n| n >= 2 && n.even? }],
    [:wheels, :typeof, Integer, Proc.new{ |n| n >= 4 && n.even? }],
    [:weight, :typeof, Numeric, Proc.new { |n| n >= 500 }],
    [:year, :typeof, Integer, Proc.new { |n| n >= 1900 } ],
    [:model, :anyof, ['SpaceCowboy', 'Peanut', 'Icarus']],
    [:coupe, :typeof, Bool],
    [:comments, :arrayof, String],
    [:custom_color, :adv_formof, [[:typeof, String],[:formof, [Float]*3, Proc.new { |n| 0 <= n && n <= 1 } ]]],
    [:engine, :kwargsof, ENGINE],
    [:options, :kwargsof, CAR_OPTIONS])
end
```
From {KwargDict#add} you can see the expected order for each definition is,
[**kword**, **typedef**, **struct**, **optional_prc**]


## Adding the HashPrint Module
Just a convenient tool for printing hashes that might contain other hashes, as
will be the case here.  For every nested hash, it'll indent by two spaces and
continute printing line by line.  You'll see the fast and dirty approach is just
to store all the valid input in a single hash for this example.

```ruby
module HashPrint
  def hash_print(hash, ident=0)
    hash.each do |k, v|
      if v.is_a?(Hash)
        puts " "*ident + "#{k}:"
        ident += 2
        hash_print(v, ident)
        ident -= 2
      else
        puts " "*ident + "#{k}: #{v}"
      end
    end
  end
end
```
## MyCar Class
I *think* this class is pretty straight forward. You tell me.  We've included
both the HashPrint and CarDict modules, and so by extension the dictionaries and
{#hash_print}.

```ruby
class MyCar

  include CarDict
  include HashPrint

  def initialize(*kwords_vals)
    @dat = {}
    set(*kwords_vals)
  end

  def [](dat_ele)
    @dat[dat_ele]
  end

  def set(*kwords_vals)
    kwords_vals.each_slice(2) do |kword, val|
      if CAR_DICT.check(kword, val)
          @dat[kword] = val
      else
        puts "Couldn't set #{kword} with #{val}"
      end
    end
  end

  def display
    hash_print(@dat)
  end

end
```
We can initialize a MyCar instance with some parameters if we
have them, or use {#set} afterwards. In this instance, {#set} will simply override
whatever was already stored in !{@dat[kword]}, so I'll leave it up to your
imagination how you'd proceed in a different context.  For instance, using {#set}
on the *kword* for *:options* would obviously just completely overwrite the
nested hash, whereas you'd probably just intended to add or modify it.  Checking
that *val* is a hash and using {Hash#merge} would be the most obvious solution.
*I'm chasing rabbits.  I only mention it because it's in the ToDo to add another
private method to {KwargTypes} that let's the user set validated data on a more
granular level, such as individual keywords in a nested KwargDict.*

{#set} will also let you know which input didn't get except. Next.

## Getting To The Point!
Here's a car you found out on an uncharted planet in the Blarglebones 9 System,
or whatever. Let's put in the information and go ahead and display it.

#### Adding the Kool Car
```ruby
kool_car = MyCar.new(:year, 1901, :coupe, true, :nickname, "Lil Peanut", :doors, 6,
  :options, {sunroof:true, sport_package:'K2', audio_package:'Loudest'},
  :custom_color, ["Ugly Green", [0.51, 0.94, 0.79]])
kool_car.set(:engine, {liters:6.0, hp:500, turbo:true}, :wheels, 8)
kool_car.set(:comments, ["The shovel was a ground-breaking invention.", 
  "What's brown and sticky? A stick.", "Found in the Blarglebones 9 System."])

kool_car.display
```
#### Output:
```
year: 1901
coupe: true
nickname: Lil Peanut
doors: 6
options:
  sunroof: true
  sport_package: K2
  audio_package: Loudest
custom_color: ["Ugly Green", [0.51, 0.94, 0.79]]
engine:
  liters: 6.0
  hp: 500
  turbo: true
wheels: 8
comments: ["The shovel was a ground-breaking invention.", "What's brown and sticky? A stick.", "Found in the Blarglebones 9 System."]
```

What if you're groggy from the trip and mess up the entry on another car?
When we run the snippet we'll find nothing but a list of errors and an empty MyCar
instance.

#### Programming When You Should Be Resting

```ruby
break_car = MyCar.new
break_car.set(:doors, 7, :wheels, 3, :weight, 400, :year, 1857, :nickname, "Escort",
  :coupe, 'yes', :comments, [1, 2, 3, 4], :custom_color, [0.5, 0.5, 0.5], 
  :engine, {supercharged:false}, :options, {heated_seats:'front only'},
  :comments, ['This is why sleep is so important. And this gem.  But mostly coffee.'])
break_car.display
```
#### Output:
```
Couldn't set doors with 7
Couldn't set wheels with 3
Couldn't set weight with 400
Couldn't set year with 1857
Couldn't set nickname with Escort
Couldn't set coupe with yes
Couldn't set comments with [1, 2, 3, 4]
Couldn't set custom_color with [0.5, 0.5, 0.5]
Couldn't set engine with {:supercharged=>false}
Couldn't set options with {:heated_seats=>"front only"}
comments: ["This is why sleep is so important. And this gem.  But mostly coffee."]
```
## Final Thoughts On This Example
Thank goodness for that nifty KDict Gem, amiright?  Now you can really put your 
collection data together quickly without having to worry about writing difficult
validation code for every example. If you come across a new space-car feature,
you can just add it to the dict without rewriting any code or breaking what you've
already got! AND you can share this nifty *gem* with friends so they too can document
their collections. It's so easy a space-gerbil could do it.