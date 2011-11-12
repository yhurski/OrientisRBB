@addendum_search
Feature: admin/prune_topics integration test
  In order to manage old topics
  admin
  wants prune topics

  Background:
    Given admin on the prune_topics page of admin panel

  Scenario: Topics not found
    When he enters days ago greater than age in days of the topic last post
    Then he should see page with message about absence topics

  Scenario: Delete topics
    When he enters number of days
    And answers to confirmation question positive
    Then topics should be removed