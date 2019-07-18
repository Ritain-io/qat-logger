@logger @stdout_redirect @color_formatting @objects
Feature: Color formatting in logs

  As a user,
  I want to have log messages standout in stdout,
  In order to have different color formatting for specific levels of logging


  @user_story#2 @exception
  Scenario: Exceptions are logged with red formatting
    Given an existing logger
    When the object "ArgumentError.new 'Exception'" is logged
    Then the message should have multiple lines and be seen with color "red" as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: Exception \(ArgumentError\) \[
    .*
    \]
    """


  @user_story#3 @array
  Scenario: Log arrays with colors
    Given an existing logger
    When the object "[1,2,3]" is logged
    Then the message should be seen with color "green" as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: \[
      \[0\] 1,
      \[1\] 2,
      \[2\] 3
    \]
    """


  @user_story#4 @hash
  Scenario: Log hashes with colors
    Given an existing logger
    When the object "{first: 1, second: 2, third: 3}" is logged
    Then the message should be seen with color "green" as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: \{
       :first => 1,
      :second => 2,
       :third => 3
    \}
    """


  @user_story#5
  Scenario: Use formatter with colors in console and no colors in file
    Given I load the "logger_channel_qat_no_colors.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: test message" with color "green"
    When I read the log file
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[INFO \] QAT::TestLogger: test message" with no color


  @user_story#6
  Scenario Outline: No colors when logging in file with any level
    Given I load the "logger_channel_qat_only_to_file_no_colors.yml" configuration file
    And an existing module logger
    And the logger has level "<level>"
    When I log the message "test message" with level "<level>"
    When I read the log file
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[<level>\s?\].*: test message" with no color

    Examples:
      | level |
      | DEBUG |
      | INFO  |
      | WARN  |
      | ERROR |
      | FATAL |


  @user_story#7 @levels
  Scenario Outline: Each log level uses a different color
    Given I load the "logger_channel_qat_info.yml" configuration file
    And an existing module logger
    And the logger has level "<level>"
    When I log the message "test message" with level "<level>"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} \[<level>\s?\].*: test message" with <color>

    Examples:
      | level | color          |
      | DEBUG | no color       |
      | INFO  | color "green"  |
      | WARN  | color "purple" |
      | ERROR | color "red"    |
      | FATAL | color "red"    |