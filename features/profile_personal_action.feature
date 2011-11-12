@addendum_search
Feature: profile/personal integration test
  In order to perform customization users parameters
  registered user
  wants change his personal settings
  
  Scenario: Change email, realname, location, website
    Given User on the personal page of his profile
    When he changes email, realname, location, website
    And he goes down Save button
    Then he should see new values in html elements