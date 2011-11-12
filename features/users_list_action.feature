@addendum_search
Feature: User search integration test
  In order to perform search along all forum users
  user
  wants to look for concrete user(s) in concrete group(s)
  
  Scenario Outline: Perform search
    Given User on the user search page
    When I fill a username field with <username>
    And I choice a user group by <user_group>
    And I choice a type of sort by <sorting>
    And I choice a type of order by <ordering>
    Then I should see <result>
    
    Scenarios: should be passed
    	       |username|user_group|sorting|ordering|result|
    	       |""|All groups|Username|Ascending|admin|
    	       |kvark|All groups|Username|Ascending|Nothing found|