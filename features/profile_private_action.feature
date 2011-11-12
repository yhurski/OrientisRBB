@addendum_search
Feature: profile/private integration test
  In order to perform customization users parameters
  registered user
  wants change his private settings

  Scenario: Change private
    Given User on the private page of his profile
    When he changes private
    And user clicks on Save button
    Then he should see new values of private