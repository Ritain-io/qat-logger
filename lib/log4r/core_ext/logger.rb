require 'log4r/logger'
##
# Log4r extension
module Log4r
  ##
  # Log4r::Logger extension
  class Logger
    #Original Log4r::Logger initializer
    alias_method :previous_initialize, :initialize
    ##
    # Creates a +Log4r::Logger+
    #
    # See log4r/logger.rb
    def initialize(_fullname, _level=nil, _additive=false, _trace=false)
      previous_initialize _fullname, _level, _additive, _trace
    end
  end
end