require_relative '../log4r/core_ext/logger'
require_relative '../log4r/core_ext/yamlconfigurator'
require_relative 'logger/core'
require_relative 'logger/version'
require_relative 'logger/formatter'
require_relative 'logger/outputter'

#Require all outputters from log4r
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'
require 'log4r/outputter/remoteoutputter'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/udpoutputter'
require 'log4r/outputter/syslogoutputter' unless Gem.win_platform?