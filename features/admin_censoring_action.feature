@addendum_search
Feature: admin/censoring integration test
  In order to manage censoring words
  admin
  wants add, edit, remove censoring words

  Background:
    Given admin on the censoring page of admin panel

  Scenario: Add censoring word
    When he adds censoring and replacement words
    And save it
    Then new pair of words should be appeared on page

  Scenario: Edit censoring word
    When he changes censoring or replacement word
    And update it
    Then updated pair of words should be appeared on page
    
  Scenario: Remove censoring word
    When he presses Remove button
    Then pair of words should be deleted