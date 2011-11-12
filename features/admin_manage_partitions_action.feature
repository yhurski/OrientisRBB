@addendum_search
Feature: Forums management integration test
  In order to perform add, edit and remove forums
  admin
  wants change his forums

  Background:
    Given admin on the manage_partitions page

  Scenario: Add forum
    When he adds new forum
    And he pushes Add forum button
    Then he should see new editable forum record on manage_partitions page

  Scenario: Edit forum
    When admin edits forum
    And he pushes Update
    Then he should see updated forum record on manage_partitions page

  Scenario: Remove forum
    When admin choices forum from list
    And he presses Delete button
    Then choices forum should be removed
