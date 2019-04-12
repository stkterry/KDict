require 'kdict.rb'

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

kool_car = MyCar.new(:year, 1901, :coupe, true, :nickname, "Lil Peanut", :doors, 6,
  :options, {sunroof:true, sport_package:'K2', audio_package:'Loudest'},
  :custom_color, ["Ugly Green", [0.51, 0.94, 0.79]])

kool_car.set(:engine, {liters:6.0, hp:500, turbo:true}, :wheels, 8)
kool_car.set(:comments, ["The shovel was a ground-breaking invention.", 
  "What's brown and sticky? A stick.", "Found in the Blarglebones 9 System."])
kool_car.display

break_car = MyCar.new
break_car.set(:doors, 7, :wheels, 3, :weight, 400, :year, 1857, :nickname, "Escort",
  :coupe, 'yes', :comments, [1, 2, 3, 4], :custom_color, [0.5, 0.5, 0.5], 
  :engine, {supercharged:false}, :options, {heated_seats:'front only'},
  :comments, ['This is why sleep is so important. And this gem.  But mostly coffee.'])
break_car.display