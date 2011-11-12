@addendum_search
Feature: admin/notices integration test
  In order to configure forum
  admin
  wants change forum notices
  
  Scenario: Change forum notices
    Given admin on the notices page of admin panel
    When he changes notices parameters
    And he saves notices values
    Then forum notices values should be updated