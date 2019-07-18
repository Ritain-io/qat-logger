# -*- encoding : utf-8 -*-
# Code coverage
require 'simplecov'
require 'qat/logger'
require_relative '../../lib/test_logger'
require_relative '../../lib/remote_logger_checker'

#Variable activated by the raketask "qat:logger:run_tests_with_debug"
if ENV['INTERNAL_DEBUGGER']
  Kernel.puts 'Log4r internal logger activated!!'

  Log4r::Logger.new 'log4r'
  Log4r::Logger['log4r'].outputters= Log4r::Outputter.stderr
end

class LoggerTestFailed < StandardError
end

World do
  RemoteLoggerChecker.new
end
