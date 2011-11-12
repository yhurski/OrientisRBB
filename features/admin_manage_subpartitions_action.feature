@addendum_search
Feature: Categories management integration test
  In order to perform add, edit and remove categories
  admin
  wants change categories

  Background:
    Given admin on the manage_subpartitions page

  Scenario: Add category
    When admin adds new category
    And he pushes Add category button
    Then he should see new category title on manage_subpartitions page

  Scenario: Edit category
    Given admin on the edit_subpartitions page
    When admin edits category data
    And he save value by clicking Save button
    Then he should see updated forum record on manage_subpartitions page

  Scenario: Remove category
    When admin clicks on link for appropriate category
    Then category should be removed
