@addendum_search
Feature: profile/view integration test
  In order to perform customization users parameters
  registered user
  wants change his view settings

  Scenario: Change view
    Given User on the view page of his profile
    When he changes view
    And user pushes Save button
    Then he should see new values of view