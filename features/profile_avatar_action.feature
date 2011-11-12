@addendum_search
Feature: profile/avatar integration test
  In order to perform customization users parameters
  registered user
  wants change his avatar

  Background:
    Given User on the avatar page of his profile

  Scenario: Change avatar
    When he upload avatar
    Then he should see avatar image on avatar page
    
  Scenario: Remove avatar
    When he removes avatar
    Then he should see "There are no available avatar"