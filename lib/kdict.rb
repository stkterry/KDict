require "kdict/version"

# KDict allows you to quickly create powerful Keyword-Argument Dictionaries.  Each
# entry (a KwargModel) can be used to validate a user's input against it,
# and is built from a generic type defintion (*typedef*) and a unique structure
# (*struct*).
#
# With the included *typedefs* users can create simple to complex validaters in
# just a single line of code.  Be sure to check out {KwargDict} and {KwargTypes}
# for a detailed look at the underlying code and how it might be used.
# Especially be sure to check out the {file:README.md} more than anything else!
module KDict
  # Inheriting SandardError.
  class Error < StandardError; end
  require 'kdict/kwargdict/kwargtypes/bool.rb'
  require 'kdict/kwargdict/kwargtypes.rb'
  require 'kdict/kwargdict.rb'
  require 'kdict/kwargmodel.rb'
end
