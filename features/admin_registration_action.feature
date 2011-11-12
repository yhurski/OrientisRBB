@addendum_search
Feature: admin/registration integration test
  In order to configure forum
  admin
  wants change forum registration settings
  
  Scenario: Change registration settings
    Given admin on the registration page of admin panel
    When he changes registration settings
    And he saves registration values
    Then forum registration values should be updated