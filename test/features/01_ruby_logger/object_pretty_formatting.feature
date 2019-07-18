@logger @stdout_redirect @pretty_formatting
Feature: Object pretty formatting in logs

  As a user,
  In order to improve log readability
  I want to have objects with a human readable formatting,

  #Validates that correct format for a log with a hash as entry parameter.
  @user_story#1
  Scenario: Log hashes in correct format
    Given an existing logger
    When the object "{first: 1, second: 2, third: 3}" is logged
    Then the message should be seen as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: \{
       :first => 1,
      :second => 2,
       :third => 3
    \}
    """


  @user_story#12 @exception
  Scenario: Log exceptions in correct format
    Given an existing logger
    When the object "ArgumentError.new 'Exception'" is logged
    Then the message should have multiple lines and be seen as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: Exception \(ArgumentError\) \[
    .*
    \]
    """


  @user_story#13 @array
  Scenario: Log arrays in correct format
    Given an existing logger
    When the object "[1,2,3]" is logged
    Then the message should be seen as
    """
    \d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: \[
      \[0\] 1,
      \[1\] 2,
      \[2\] 3
    \]
    """


  @user_story#14 @string
  Scenario: Log string in correct format
    Given an existing logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} .*: test message"


  @user_story#15 @date
  Scenario: The current date is logged in correct format
    Given an existing logger
    When I log the message "test message"
    Then the message should be seen as "\d{4}-\d\d-\d\d \d\d:\d\d:\d\d,\d{3} "
