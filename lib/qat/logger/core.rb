require 'log4r'

module QAT
  module Logger
    include Log4r

    ##
    # The default outputter for QAT's logger
    DEFAULT_OUTPUTTER_NAME = 'qat_console_outputter'

    ##
    # Sets up the logging capabilities for +base+
    # when QAT::Logger is included in a +base+ module/class.
    def self.included base
      logging_function_code = <<-RUBY
        def log
          log_obj = Log4r::Logger["#{base.name}"]

          unless log_obj
            log_obj = Log4r::Logger.new "#{base.name}"
            log_obj.outputters = Log4r::Outputter[DEFAULT_OUTPUTTER_NAME] || ConsoleOutputter.new(DEFAULT_OUTPUTTER_NAME)
          end

          log_obj
        end
        private :log
      RUBY

      base.module_eval <<-RUBY, __FILE__, __LINE__+1
        #{logging_function_code}
        class << self
          #{logging_function_code}
        end
      RUBY
    end
  end
end
