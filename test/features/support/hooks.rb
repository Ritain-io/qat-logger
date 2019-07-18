Around '@stdout_redirect' do |_, block|
  Log4r::Logger.root.level = Log4r::ALL

  log_channels_tested = ['QAT::TestLogger',
                         'QAT::TestLogger::Submodule',
                         'Test::TestLogger::Singleton',
                         'Test::TestLogger::Instance',
                         'Test::DummyLogger']

  log_channels_tested.each do |log_channel|
    if Log4r::Logger[log_channel]
      log            = Log4r::Logger.new log_channel, nil, false
      log.outputters = Log4r::Outputter[QAT::Logger::DEFAULT_OUTPUTTER_NAME] || QAT::Logger::ConsoleOutputter.new(QAT::Logger::DEFAULT_OUTPUTTER_NAME)
    end
  end

  $sio                 ||= StringIO.new
  @old_stdout, $stdout = $stdout, $sio
  @old_stdout.sync     = true

  block.call

  $stdout = @old_stdout
  Dir[File.join(File.dirname(__FILE__), '..', '..', 'public', '*.log')].each do |log_file|
    File.delete(log_file)
    Log4r::Logger.log_internal { "DELETED: '#{log_file}'" }
  end
end
