@logger @stdout_redirect @channels
Feature: Logging channels and levels configuration

  As a user,
  I want to be able to configure the different logging channels and levels for my logger,
  In order to see only relevant messages from each source


  @user_story#8 @configuration
  Scenario: Configure various outputs
    Given I load the "logger_channel_to_file.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: test message"
    When I read the log file
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: test message"


  @user_story#9 @configuration
  Scenario: Configure a logger sub-channel with a higher level of logging than the parent channel
    Given I load the "logger_channel_submodule_trace.yml" configuration file
    And an existing module logger
    When I log the message "debug message" with level "debug"
    Then no message should have been logged
    When I log the message "info message" with level "info"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: info message"

    And an existing submodule logger
    When I log the message "sub module debug message" with level "debug"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[DEBUG\] logging\.rb:\d+: sub module debug message"


  @user_story#10 @configuration @global @levels
  Scenario: Control all loggers with one level configuration
    Given I load the configuration
    """
    log4r_config:
      pre_config:
        global:
          level: 'WARN'
    """
    And an existing logger
    When I log the message "test message" with level "INFO"
    Then no message should have been logged
    When I log the message "test message" with level "WARN"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[WARN \] Test::DummyLogger: test message"


  @user_story#11 @configuration
  Scenario: Create a logger channel from configuration string
    Given I load the configuration
    """
    log4r_config:
      pre_config:
        global:
          level: 'INFO'
    """
    And an existing logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] Test::DummyLogger: test message"


  @user_story#11 @configuration
  Scenario: Use a logger channel not configured in a file
    Given I load the "logger_channel_qat_info.yml" configuration file
    And an existing instance logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] Test::TestLogger::Instance: test message"


  @user_story#16 @configuration @inheritance @levels
  Scenario: Logging different levels for different channels with inheritance
    Given an existing module logger
    And the logger has level "ERROR"
    When I log the message "INFO message" with level "INFO"
    Then no message should have been logged
    When I log the message "ERROR message" with level "ERROR"
    Then the message should be seen as "\[ERROR\] QAT::TestLogger\: ERROR message"


    Given an existing submodule logger
    And the logger has level "DEBUG"
    When I log the message "DEBUG message" with level "DEBUG"
    Then the message should be seen as "\[DEBUG\] QAT::TestLogger::Submodule\: DEBUG message"


    Given an existing module logger
    When I log the message "INFO message" with level "INFO"
    Then no message should have been logged
    When I log the message "ERROR message" with level "ERROR"
    Then the message should be seen as "\[ERROR\] QAT::TestLogger\: ERROR message"


  @user_story#17 @configuration @levels
  Scenario: Different logging levels can coexist in different channels
    Given an existing singleton logger
    And the logger has level "ERROR"
    When I log the message "INFO message" with level "INFO"
    Then no message should have been logged

    Given an existing instance logger
    And the logger has level "DEBUG"
    When I log the message "DEBUG message" with level "DEBUG"
    Then the message should be seen as "\[DEBUG\] Test::TestLogger::Instance\: DEBUG message"

    Given an existing singleton logger
    When I log the message "INFO message" with level "INFO"
    Then no message should have been logged


  @user_story#18 @defaults @levels
  Scenario Outline: All the logging levels are available in all the logging channels by default
    Given an existing <type> logger
    When I log the message "this is a test message" with level "<level>"
    Then the message should be seen as "\[<level>\s?\] .*: this is a test message"

    Examples:
      | type      | level |
      | singleton | DEBUG |
      | singleton | INFO  |
      | singleton | WARN  |
      | singleton | ERROR |
      | singleton | FATAL |
      | instance  | DEBUG |
      | instance  | INFO  |
      | instance  | WARN  |
      | instance  | ERROR |
      | instance  | FATAL |
      | module    | DEBUG |
      | module    | INFO  |
      | module    | WARN  |
      | module    | ERROR |
      | module    | FATAL |
      | submodule | DEBUG |
      | submodule | INFO  |
      | submodule | WARN  |
      | submodule | ERROR |
      | submodule | FATAL |


  @user_story#18
  Scenario Outline: The correct logging channel is used for different logger calls
    Given an existing <type> logger
    When I log the message "this is a test message" with level "INFO"
    Then the message should be seen as "<source>\: this is a test message"

    Examples:
      | type      | source                      |
      | singleton | Test::TestLogger::Singleton |
      | instance  | Test::TestLogger::Instance  |
      | module    | QAT::TestLogger             |
      | submodule | QAT::TestLogger::Submodule  |


  @user_story#19 @configuration
  Scenario: Create a specific logger channel from configuration file
    Given I load the "logger_channel_qat_info.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: test message"


  #Validates that when logging with the all possible level and activating the trace option, the channel is replaced by the originating file/line.
  @user_story#20 @levels
  Scenario Outline: Activating trace disables log channel printing
    Given an existing logger
    And the logger has level "ALL"
    And the logger "has" trace enabled
    When I log the message "Normal Message" with level "<level>"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[<printed_level>\] logging.rb:\d+: Normal Message"
    Examples:
      | level | printed_level |
      | DEBUG | DEBUG         |
      | INFO  | INFO\s        |
      | WARN  | WARN\s        |
      | ERROR | ERROR         |
      | FATAL | FATAL         |


  #Validates that transitions between logging levels has impact on wich messages are displayed in STDOUT.
  #Lower level messages aren't displayed in a upper level.
  @user_story#21 @levels
  Scenario Outline: Log level can be adjusted
    Given an existing <type> logger
    And the logger has level "<log_level>"
    When I log the message "this is a test message" with level "<log_level>"
    Then the message should be seen as "this is a test message"

    Given the logger has level "<next_level>"
    When I log the message "this is another test message" with level "<log_level>"
    Then no message should have been logged

    Examples:
      | type      | log_level | next_level |
      | singleton | DEBUG     | INFO       |
      | singleton | INFO      | WARN       |
      | singleton | WARN      | ERROR      |
      | singleton | ERROR     | FATAL      |
      | singleton | FATAL     | OFF        |
      | instance  | DEBUG     | INFO       |
      | instance  | INFO      | WARN       |
      | instance  | WARN      | ERROR      |
      | instance  | ERROR     | FATAL      |
      | instance  | FATAL     | OFF        |
      | module    | DEBUG     | INFO       |
      | module    | INFO      | WARN       |
      | module    | WARN      | ERROR      |
      | module    | ERROR     | FATAL      |
      | module    | FATAL     | OFF        |
      | submodule | DEBUG     | INFO       |
      | submodule | INFO      | WARN       |
      | submodule | WARN      | ERROR      |
      | submodule | ERROR     | FATAL      |
      | submodule | FATAL     | OFF        |