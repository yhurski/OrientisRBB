@addendum_search
Feature: admin/maintenance integration test
  In order to manage forum parameters
  admin
  wants to maintain forum


  Scenario: Switch to maintenance mode
    Given admin on the maintenance of admin panel
    When he enables maintenance mode and writes message
    Then he should see page with message and enabled maintenance mode

  Scenario: User should see maintenance message
    Given forum swithed in maintenance mode
    When user comes to forum_page
    Then he should see maintenance message
    
    Scenarios: various forum pages
    |forum_page|
    |'/forum/main'|
    |'/forum/users_list'|
    |'/profile/main'|