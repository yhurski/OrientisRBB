@addendum_search
Feature: profile/individual integration test
  In order to perform customization users parameters
  registered user
  wants change his individual settings

  Scenario: Change signature
    Given User on the individual page of his profile
    When he changes signature
    And he pushes Save button
    Then he should see new values of signature