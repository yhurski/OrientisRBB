@addendum_search
Feature: admin/features integration test
  In order to configure forum features
  admin
  wants change his setup settings
  
  Scenario: Change forum features
    Given admin on the features page of admin panel
    When he changes features parameters
    And Save button was pressed
    Then forum feature values should be saved