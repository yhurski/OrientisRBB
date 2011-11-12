@addendum_search
Feature: admin/reports integration test
  In order to manage users reports
  admin
  wants view and close reports

  Background:
    Given admin on the reports page of admin panel
    When he adds new report direct into db

  Scenario: View report
    Then he should see new report on page

  Scenario: Close report
    When he clicks on 'Select all' link and clicks on 'Update' button
    Then report page should be empty