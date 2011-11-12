@addendum_search
Feature: admin/groups integration test
  In order to perform user groups management
  admin
  wants to view, create, edit, remove and set as default groups
  
  Background:
    Given admin on the groups page of admin panel
  
  Scenario: Performing view all groups
    Then he should see all group names on page
    
  Scenario: Creating new group that base on existing one
    When he presses 'Create new group' button
    And he sets some new group parameters
    And he presses 'Update' button
    Then he should see new group name on page
    
  Scenario: Editing default group
    When he load edit_group page with default group
    When he changes some parameters in default group
    Then he should see update values for default group
    
   Scenario: Set default group
      When he presses 'Set default group'
      Then default group will be set