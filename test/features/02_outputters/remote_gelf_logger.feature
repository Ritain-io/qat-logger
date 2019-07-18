@logger @stdout_redirect @remote @outputter @gelf
Feature: Custom remote formatter and outputter

  Background:
    Given I load a remote logger configuration
    And an existing module logger


  @user_story#22
  Scenario Outline: Logging all the log levels to ElasticSearch
    When I log the message "this is a test message" with level "<level>"
    Then no message should have been logged to the console
    Then the message in the remote server should be correct

    Examples:
      | level |
      | DEBUG |
      | INFO  |
      | WARN  |
      | ERROR |
      | FATAL |


  @user_story#23
  Scenario Outline: Log complex objects in correct format to ElasticSearch
    When the object "<object>" is logged
    Then no message should have been logged to the console
    Then the message in the remote server should be correct

    Examples:
      | object                          |
      | {first: 1, second: 2, third: 3} |
      | [1,2,3]                         |
      | ArgumentError.new 'Exception'   |


  @user_story#24
  Scenario: Log complex objects in correct format to ElasticSearch
    When I log a remote Selenium exception
    Then no message should have been logged to the console
    Then the message in the remote server should be correct