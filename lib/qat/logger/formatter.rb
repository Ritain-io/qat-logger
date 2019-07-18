require 'log4r/formatter/patternformatter'
require 'awesome_print'
require 'gelf'
require 'time'
require_relative 'version'

module QAT
  module Logger
    ##
    # This class represents a formatter used by the logging outputters instances
    #
    # See QAT::Logger::ConsoleOutputter
    # See QAT::Logger::RemoteOutputter
    class Formatter < Log4r::Formatter

      ##
      # Level to color mapping
      LEVEL_COLORS = Hash.new(:to_s).merge({
                                             'INFO'  => :green,
                                             'WARN'  => :purple,
                                             'ERROR' => :red,
                                             'FATAL' => :red
                                           })

      ##
      # Accessors for formatter properties
      attr_accessor :colors, :date_pattern

      ##
      # Creates a new formatter with an user defined hash of +options+.
      #
      # Options are:
      # - 'colors' [Boolean] Default is true.
      # - 'date_pattern' [String] Default is '%Y-%m-%d %H:%M:%S,%L'.
      def initialize(opts={})
        Log4r::Logger.log_internal { "Starting new formatter with options" }
        Log4r::Logger.log_internal { opts.ai }
        @colors       = opts['colors'].nil? ? true : opts['colors']
        @date_pattern = opts['date_pattern'] || '%Y-%m-%d %H:%M:%S,%L'
      end

      ##
      # Formats the +event+ to be logged.
      def format(event)
        date = Time.now.strftime(@date_pattern.to_s)

        level_name = Log4r::LNAMES[event.level]
        level      = sprintf "%-5s", level_name

        channel_info = if event.tracer
                         event.tracer[0].split(File::SEPARATOR)[-1].match(/(.+:\d+)(?::in `.+')/).captures.first
                       else
                         event.fullname
                       end

        logged_object = case event.data
                          when Exception
                            "#{event.data.message} (#{event.data.class}) #{event.data.backtrace.ai plain:  true,
                                                                                                   index:  false,
                                                                                                   indent: 2}"
                          when String
                            event.data
                          else
                            event.data.ai plain:  true,
                                          indent: 2
                        end

        color_method = @colors ? LEVEL_COLORS[level_name] : :to_s

        "#{date} [#{level}] #{channel_info}: #{logged_object}".send(color_method) + "\n"
      end

    end
  end
end

#@api private
# QatFormatter in Log4r
Log4r::QatFormatter = QAT::Logger::Formatter
