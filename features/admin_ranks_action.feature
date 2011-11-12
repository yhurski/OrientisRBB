@addendum_search
Feature: admin/ranks integration test
  In order to manage ranks
  admin
  wants add, edit, remove ranks

  Background:
    Given admin on the ranks page of admin panel

  Scenario: Add rank
    When he adds rank title and rank post amount
    And save it in db
    Then new record of rank should be appeared

  Scenario: Edit rank
    When he changes title or post amount of rank
    And he renews page
    Then updated pair of words should be appeared in db
    
  Scenario: Remove rank
    When he presses Remove button
    Then pair of rank title - post amount should be deleted