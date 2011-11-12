@addendum_search
Feature: admin/bans integration test
  In order to manage banned users
  admin
  wants add, edit, remove bans

  Background:
    Given admin on the bans page of admin panel

  Scenario: Add ban
    When he adds user name for ban and press 'Add ban' button
    And he should edit ban expiration date on add_edit_ban page
    And he clicks on 'Save' ban button
    Then new ban record should be appeared on bans page

  Scenario: Edit ban
    When he goes to add_edit_ban page for a existing user    
    And he adds ban message
    Then ban message for a banned user should be appeared in db
    
  Scenario: Remove ban
    When he presses Remove link for a banned
    Then banned user should be removed from db