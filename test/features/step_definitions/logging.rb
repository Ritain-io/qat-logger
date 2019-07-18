#encoding: utf-8

Given /^an existing (?:(module|submodule|singleton|instance) )?logger$/ do |type|
  if type
    @logger = case type
              when 'module' then
                QAT::TestLogger
              when 'submodule' then
                QAT::TestLogger::Submodule
              when 'singleton' then
                Test::TestLogger::Singleton
              when 'instance' then
                Test::TestLogger::Instance.new
              else
                pending("Logger tester type not supported: '#{type}'")
              end
  else
    @logger                 = Test::DummyLogger
    @logger.log_proxy.level = Log4r::LNAMES.index('INFO')
  end
end

Given /^the logger has level "([^"]*)"$/ do |level|
  @logger.log_proxy.level = Log4r::LNAMES.index(level.upcase)
end

Given /^the logger "(has|hasn't)" trace enabled$/ do |trace|
  @logger.log_proxy.trace = (trace == 'has')
end

When /^I log the message "([^"]*)"(?: with level "([^"]*)")?$/ do |message, level|

  temp = $sio.string.size

  level         ||= 'info'
  expected_line = {
    'level_name' => level.upcase,
    'level'      => GELF::DIRECT_MAPPING[GELF::Levels.const_get(level.upcase)],
    'facility'   => 'QAT Remote Logger Test'
  }


  @logger.log_proxy.send(level.downcase, message)
  if @logger.log_proxy.trace
    expected_line.merge!({
                           'file'          => File.expand_path(__FILE__),
                           'line'          => "#{(__LINE__.to_i - 4)}",
                           'short_message' => message
                         })
  else
    expected_line.merge!({ 'message' => message })
  end


  #Cut what was previously logged
  @logged_line = $sio.string[temp..-1]
  Log4r::Logger.log_internal { "LOGGED: '#{@logged_line}'" }

  register_line expected_line
  Log4r::Logger.log_internal { "EXPECTED LINE: '#{self.expected_line}'" }
end

When /^the object "([^"]*)" is logged$/ do |obj|

  temp = $sio.string.size if $sio

  printable_obj = eval(obj)

  expected_line = {
    'facility' => 'QAT Remote Logger Test'
  }

  if printable_obj.is_a?(StandardError)
    begin
      raise printable_obj
    rescue => error
      if Log4r::Outputter['logstash_output']
        expected_line['short_message'] = "Caught #{error.class}: #{error.message}"
        expected_line['message']       = "Backtrace:\n#{error.backtrace.join("\n")}"
        expected_line['exception']     = error.class.name.to_s
        expected_line['level']         = GELF::Levels::ERROR
        expected_line['level_name']    = 'ERROR'
      end

      @logger.log_proxy.error(error)
      if @logger.log_proxy.trace
        expected_line.merge!({
                               'file' => (File.expand_path(__FILE__)),
                               'line' => "#{(__LINE__.to_i - 14)}"
                             })
      end
      Log4r::Logger.log_internal { "Expected:\n'#{expected_line.awesome_inspect}'" }
    end
  else
    expected_line['short_message'] = printable_obj.to_s
    @logger.log_proxy.info(printable_obj)
    if @logger.log_proxy.trace
      expected_line.merge!({
                             'file' => File.expand_path(__FILE__),
                             'line' => "#{(__LINE__.to_i - 4)}"
                           })
    end
  end

  #Cut what was previously logged
  @logged_line = $sio.string[temp..-1]
  Log4r::Logger.log_internal { "LOGGED: '#{@logged_line}'" }
  register_line expected_line
end

When /I read the log file/ do
  @logged_line = File.read Dir[File.join(Dir.pwd, 'public', '*.log')][0]
  Log4r::Logger.log_internal { "LOGGED IN FILE: '#{@logged_line}'" }
end


Then /^the message should be seen as "([^"]*)"(?: with (?:(?:color "([^"]*)")?|(no color)?)?)?$/ do |regex_string, color, no_color|
  case color
  when 'red'
    regex_string = "^\\e\\[1;31m#{regex_string}\\e\\[0m\\n$"
  when 'green'
    regex_string = "^\\e\\[1;32m#{regex_string}\\e\\[0m\\n$"
  when 'purple'
    regex_string = "^\\e\\[1;35m#{regex_string}\\e\\[0m\\n$"
  when 'cyan'
    regex_string = "^\\e\\[1;36m#{regex_string}\\e\\[0m\\n$"
  else
    regex_string = "^#{regex_string}\\n$" if no_color
  end

  regex       = Regexp.new(regex_string)
  logged_line = @logged_line.bytes.to_a.select { |c| c.between?(32, 126) }.map { |c| c.chr }.join
  raise(LoggerTestFailed, "The message '#{logged_line}' does not match the regex #{regex_string.strip}") unless regex.match(@logged_line)
  raise(LoggerTestFailed, "The message '#{logged_line}' doen't have one line!") unless @logged_line.split("\n").size == 1
end


Then /^the message should( have multiple lines and)? be seen(?: with (?:(?:color "([^"]*)")?|(no color)?)?)? as$/ do |lines, color, no_color, text|
  if lines
    minimum_lines = 5
    lines_found   = @logged_line.split("\n").size
    raise(LoggerTestFailed, "The message has #{lines_found}, expected it to have at least #{minimum_lines} lines") if lines_found < minimum_lines
  end
  case color
  when 'red'
    text = "^\\e\\[1;31m#{text}\\e\\[0m\\n$"
  when 'green'
    text = "^\\e\\[1;32m#{text}\\e\\[0m\\n$"
  when 'purple'
    text = "^\\e\\[1;35m#{text}\\e\\[0m\\n$"
  when 'cyan'
    text = "^\\e\\[1;36m#{text}\\e\\[0m\\n$"
  else
    text = "^#{text}\\n$" if no_color
  end

  regex       = Regexp.new(text, Regexp::MULTILINE)
  logged_line = @logged_line.bytes.to_a.select { |c| c.between?(32, 126) }.map(&:chr).join
  raise(LoggerTestFailed, "The message '#{logged_line}' does not match the regex #{text}") unless regex.match(@logged_line)
end


Then /^no message should have been logged(?: to the console)?$/ do
  logged_line = @logged_line.bytes.to_a.select { |c| c.between?(32, 126) }.map(&:chr).join
  raise(LoggerTestFailed, "A message was found: '#{logged_line}'") unless @logged_line.strip.empty?
end

Given /I load the "([^"]*)" configuration file/ do |file|
  Log4r::YamlConfigurator.load_yaml_file(File.join(Dir.pwd, 'config', file))
end

Given /I load the configuration/ do |yml|
  Log4r::Logger.log_internal { "YAML: \n'#{yml}'" }

  Log4r::YamlConfigurator.load_yaml_string(yml)
end

Given /I load a remote logger configuration/ do
  Log4r::YamlConfigurator.load_yaml_file(File.join(Dir.pwd, 'config', 'logger_remote.yml'))
end

Then /the message in the remote server should be correct/ do
  raise(LoggerTestFailed, "Expected line not found:\n#{self.expected_line}") unless line_valid?
end

And(/^there (?:are|is) (no|\d+) log files?$/) do |number|
  number = 0 if number == 'no'

  files = Dir[File.join(Dir.pwd, 'public', '*.log')].count

  raise(LoggerTestFailed, "Expected to find #{number} log files but found #{files}") unless number.to_i == files

end

When(/^I rotate the file outputter$/) do

  @created_file = @logger.log_proxy.outputters.first.roll_file
end


Then(/^the file outputter returns the created file name$/) do
  files = Dir[File.join(Dir.pwd, 'public', '*.log')]
  files.sort_by { |file| File.mtime(file) }
  file_expected = files[-2]
  raise(LoggerTestFailed, "Expected to find a file #{file_expected} but found a file #{File.expand_path(@created_file)}") unless file_expected == File.expand_path(@created_file)
end

When(/^I log a remote Selenium exception$/) do

  temp = $sio.string.size if $sio

  expected_line = {
    'facility' => 'QAT Remote Logger Test'
  }

  remote_file = '[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/command-processor.js'
  random_line = rand(1000..9999)

  begin
    raise StandardError,
          'Error: An error occurred while processing the request.',
          [
            "#{remote_file}:#{random_line}:in `nsCommandProcessor.prototype.execute'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/driver-component.js:9558:in `Dispatcher.executeAs/<'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/driver-component.js:9705:in `Resource.prototype.handle'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/driver-component.js:9652:in `Dispatcher.prototype.dispatch'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/driver-component.js:12517:in `WebDriverServer/<.handle'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:2054:in `createHandlerFunc/<'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:2387:in `ServerHandler.prototype.handleResponse'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:1223:in `Connection.prototype.process'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:1677:in `RequestReader.prototype._handleResponse'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:1525:in `RequestReader.prototype._processBody'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/httpd.js:1393:in `RequestReader.prototype.onInputStreamReady'",
            "[remote server] resource://gre/components/nsPrompter.js:360:in `openModalWindow'",
            "[remote server] resource://gre/components/nsPrompter.js:550:in `ModalPrompter.prototype.openPrompt'",
            "[remote server] resource://gre/components/nsPrompter.js:602:in `ModalPrompter.prototype.alert'",
            "[remote server] file:///tmp/webdriver-profile20170716-23318-knzv78/extensions/fxdriver@googlecode.com/components/prompt-service.js:4745:in `ObservingAlert.prototype.alert'",
         ]
  rescue => error
    if Log4r::Outputter['logstash_output']
      expected_line['short_message'] = "Caught #{error.class}: #{error.message}"
      expected_line['message']       = "Backtrace:\n#{error.backtrace.join("\n")}"
      expected_line['exception']     = error.class.name.to_s
      expected_line['level']         = GELF::Levels::ERROR
      expected_line['level_name']    = 'ERROR'
    end

    @logger.log_proxy.error(error)
    if @logger.log_proxy.trace
      expected_line.merge!({
                             'file' => remote_file,
                             'line' => "#{random_line}"
                           })
    end
    Log4r::Logger.log_internal { "Expected:\n'#{expected_line.awesome_inspect}'" }
  end

  #Cut what was previously logged
  @logged_line = $sio.string[temp..-1]
  Log4r::Logger.log_internal { "LOGGED: '#{@logged_line}'" }
  register_line expected_line
end

Then(/^the previous file is the same file returned on rotate$/) do
  previous_file = @logger.log_proxy.outputters.first.previous_file
  raise(LoggerTestFailed, "Expected to find a file #{previous_file} but found a file #{@created_file}") unless previous_file == @created_file
end