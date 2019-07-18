require 'log4r/outputter/consoleoutputters'
require_relative '../formatter'

module QAT
  module Logger
    ##
    # This class represents a generic console output handler
    class ConsoleOutputter < Log4r::StdoutOutputter
      ##
      # Creates a output handler for logging to the console named +name+ with +options+.
      #
      # Default options are:
      # - 'formatter' = QAT::Logger::Formatter.new('colors' => true)
      # - 'level' = Log4r::ALL
      #
      # See QAT::Logger::Formatter
      # See Log4r::StdoutOutputter
      # See Log4r::ALL
      def initialize name, opts={}
        default = { formatter: QAT::Logger::Formatter.new('colors' => true),
                    level:     Log4r::ALL }
        super name, default.merge(opts)
      end

    end
  end
end

#@api private
# QatConsoleOutputter in Log4r
Log4r::QatConsoleOutputter = QAT::Logger::ConsoleOutputter
