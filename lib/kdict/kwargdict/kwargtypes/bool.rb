# A useful collection of monkey-wrenching that makes creating KwargTypes and
# KwargModels a little simpler.

# Empty module that's assigned to both {TrueClass} and {FalseClass}.
module Bool; end
# Adds the {Bool} module to {TrueClass}.
class TrueClass; include Bool; end
# Adds the {Bool} module to {FalseClass}.
class FalseClass; include Bool; end