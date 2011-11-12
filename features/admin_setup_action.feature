@addendum_search
Feature: admin/setup integration test
  In order to perform set up forum parameters
  admin
  wants change his setup settings
  
  Scenario: Change setup settings
    Given admin on the setup page of admin panel
    When he changes setup parameters
    And Save button
    Then he should see saved values in html elements