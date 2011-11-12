@addendum_search
Feature: admin/attach integration test
  In order to configure forum
  admin
  wants change forum registration settings
  
  Background:
    Given admin on the attach page of admin panel
  
  Scenario: Change attach settings
    When he changes attach settings
    And he saves attach values
    Then attach values should be updated
    
  Scenario: Add attach icon
    When he adds new attach icon record
    And he saves
    Then should appear new icon record on page
    
  Scenario: Remove attach icon
    When he clears extension and file name fields of exist icon record
    And he saves it
    Then icon record should be removed  