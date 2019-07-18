require 'forwardable'
require 'log4r-gelf'
require 'log4r/formatter/formatter'

module QAT
  module Logger
    class RemoteOutputter < Log4r::GelfOutputter
      # This class is a message holder for the RemoteOutputter
      class Message
        extend Forwardable

        attr_reader :content, :log_event, :formatter

        def_delegators :@content, *(Hash.public_instance_methods(false))

        # Regex used to extract file and line information from log events
        LINE_PARSER = /^(.*):(\d+)(:in \`(.*)')?/

        def initialize(log_event, level, level_name, formatter)
          @log_event                 = log_event
          @content                   = {}
          @content[:level]           = level
          @content['_level_name']    = level_name
          @content["_logger"]        = log_event.fullname
          @content["_log_timestamp"] = Time.now.iso8601(3)

          @formatter = formatter

          set_full_message
          set_short_message
        end

        private

        # Sets the full_message field in the message to be sent containing the complete exception backtrace if one exists.
        def set_full_message
          data   = log_event.data
          tracer = log_event.tracer

          if data.respond_to?(:backtrace)
            extract_from_data(data)
          elsif tracer
            extract_from_tracer(tracer)
          end
        end

        def extract_from_data(data)
          backtrace = data.backtrace
          klass     = data.class

          if backtrace
            @content["_exception"]           = klass.inspect
            @content[:short_message]         = "Caught #{klass}: #{data.message}"
            @content[:full_message]          = "Backtrace:\n" + backtrace.join("\n")
            @content[:file], @content[:line] = backtrace.first.match(LINE_PARSER).captures
          end
        end

        def extract_from_tracer(tracer)
          backtrace = tracer.join("\n")

          @content[:full_message]              = "#{@content[:full_message]}\nLog tracer:\n#{backtrace}"
          @content[:file], @content[:line], *_ = tracer.first.split(":")
        end

        # Extract any context values out of the log_event's data hash.
        # The graylog2 adapter for Lograge will do this, for example.
        def set_short_message
          data = log_event.data

          if data.respond_to?(:has_key?)
            data.each do |key, value|
              if key.to_s =~ /^_/
                @content[key] = value
              end
            end

            @content[:short_message] = data[:short_message] if data.has_key?(:short_message)
          end

          @content[:short_message] = format(@log_event) unless @content[:short_message]
        end

        def format(log_event)
          @formatter.format(log_event).rstrip
        end
      end
    end
  end
end