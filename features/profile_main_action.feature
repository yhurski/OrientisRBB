@addendum_search
Feature: profile/main integration test
  In order to perform customization users parameters
  registered user
  wants change his time zone, dst, forum language
  
  Scenario: Change time zone, dst, forum language
    Given User on the main page of his profile
    When he changes tz, dst, lang
    And he presses Save button
    Then he should be redirected