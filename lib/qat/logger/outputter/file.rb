# Log4r 1.1.10 still calls File.exists?, removed in Ruby 3.2.
unless File.respond_to?(:exists?)
  class << File
    alias_method :exists?, :exist?
  end
end

require 'log4r/outputter/rollingfileoutputter'
require_relative '../formatter'

module QAT
  module Logger
    ##
    # This class represents a generic RollingFile output handler
    class RollingFileOutputter < Log4r::RollingFileOutputter

      attr_reader :previous_file
    ##
    # Creates a output handler for File logging logging using RollingFileOutputter,
    # named +name+ with a an options +hash+.
    #
    # Default options are:
    # - 'filename' = 'public/logger_testing.log' defined on yaml file configuration
    # - 'trunc' = 'true' defined on yaml file configuration
    #
    # See QAT::Logger::Formatter
    # See Log4r::RollingFileOutputter
    # See Log4r::FileOutputter
    # See Log4r::ALL
      def initialize name, hash={}
        super name, hash
      end

     # roll the file
      def roll_file
        # call the roll method of Log4r::RollingFileOutputter
        get_filename
        roll
        previous_file
      end

      private
      # Returns the previous file name
      def get_filename
        @previous_file = @filename
      end

    end
  end
end

#@api private
# QatFileOutputter in Log4r
Log4r::QatFileOutputter = QAT::Logger::RollingFileOutputter