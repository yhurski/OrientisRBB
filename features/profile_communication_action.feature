@addendum_search
Feature: profile/communication integration test
  In order to perform customization users parameters
  registered user
  wants change his communication settings

  Scenario: Change jabber, icq, msn, aol im, yahoo msn
    Given User on the communication page of his profile
    When he changes jabber, icq, msn, aol im, yahoo msn
    And he clicks Save button
    Then he should see new values of jabber, icq, msn, aol im, yahoo msn