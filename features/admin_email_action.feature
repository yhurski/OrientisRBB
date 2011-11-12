@addendum_search
Feature: admin/email integration test
  In order to configure forum
  admin
  wants change forum e-mail settings
  
  Scenario: Change e-mail settings
    Given admin on the e-mail page of admin panel
    When he changes e-mail settings
    And he saves e-mail values
    Then forum e-mail values should be updated