require 'log4r-gelf'
require_relative 'remote/message'

module QAT
  module Logger
    ##
    # This class represents a generic remote output handler
    class RemoteOutputter < Log4r::GelfOutputter
      ##
      # Creates a output handler for remote logging using GELF,
      # named +name+ with a an options +hash+.
      #
      # Default options are:
      # - 'mapped_context_prefix' = ''
      #
      # See Log4r::GelfOutputter
      def initialize name, hash = {}
        super name, { 'mapped_context_prefix' => '' }.merge(hash)
      end

      ##
      # Formats the +value+ to be logged.
      def format(value)
        super(value)
      end

      private

      ##
      # Collects logging information from the +logevent+ and sends the GELF message.
      def canonical_log(logevent)
        level_name = get_level_name(logevent)
        level      = get_level(level_name)

        @message = Message.new(logevent, level, level_name, @formatter)

        gdc = Log4r::GDC.get
        if gdc && gdc != $0 && @gdc_key
          begin
            @message["_#{@gdc_key}"] = gdc
          rescue
          end
        end

        if Log4r::NDC.get_depth > 0 && @ndc_prefix
          Log4r::NDC.clone_stack.each_with_index do |stack_value, index|
            begin
              @message["_#{@ndc_prefix}#{index}"] = stack_value
            rescue
            end
          end
        end

        mdc = Log4r::MDC.get_context
        if mdc && mdc.size > 0 && @mdc_prefix
          mdc.each do |key, value|
            begin
              @message["_#{@mdc_prefix}#{key}"] = value
            rescue
            end
          end
        end

        Log4r::Logger.log_internal { "Sending message to remote logger server:" }
        Log4r::Logger.log_internal { @message }

        @notifier.notify!(@message)
      rescue => exception
        Log4r::Logger.log_internal { "Graylog2 logger. Could not send message: #{exception.message}" }
        Log4r::Logger.log_internal { exception.backtrace.join("\n") } if exception.backtrace
      end

      def get_level_name(log_event)
        Log4r::LNAMES[log_event.level]
      end

      def get_level(level_name)
        LEVELS_MAP[level_name] || GELF::Levels::DEBUG
      end
    end
  end
end

#@api private
# QatRemoteOutputter in Log4r
Log4r::QatRemoteOutputter = QAT::Logger::RemoteOutputter
