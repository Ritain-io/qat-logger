@stdout_redirect @outputter @file @file_rotate
Feature: Outputter with file rotate on demand
  As a tester,
  In order to log to a file but only in a specific context,
  I want to have a file outputter with rotation on demand


  Scenario: Rotate on demand
    Given there are no log files
    And I load the "logger_rolling_file.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then there is 1 log file
    When I rotate the file outputter
    And I log the message "test message"
    Then there are 2 log files


  Scenario: Rotate returns the created file name
    Given there are no log files
    And I load the "logger_rolling_file.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then there is 1 log file
    When I rotate the file outputter
    Then the file outputter returns the created file name


  Scenario: Rotate and get a previous file name
    Given there are no log files
    And I load the "logger_rolling_file.yml" configuration file
    And an existing module logger
    When I log the message "test message"
    Then there is 1 log file
    When I rotate the file outputter
    Then the previous file is the same file returned on rotate
    When I log the message "test message"
    Then there are 2 log file
    When I rotate the file outputter
    Then there are 3 log file
    Then the previous file is the same file returned on rotate