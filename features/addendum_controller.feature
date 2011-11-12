@addendum_search @announce 
Feature: Addendum controller  integration test
  In order to perform search in forum post messages
  user
  wants to look for  the posts with an appropriate keyword(s)
  
  Background: 
    Given User on the search page
  
  Scenario: Return no search results 
    When I press search button
    Then I should come to search results page
  
  Scenario: Return result by existing keyword
    When I fill in a keyword text field with "test"
    And I press search button
    Then I should see result post
    
    
    # Scenario Outline: Perform search
    #   When I fill a keyword field with <search_word> and a author field with <author_name>
    #   And I choice a <forum_partition>
    #   And I choice a type of <sorting> 
    #   And I choice a type of <ordering>
    #   And I choice a type of <showing_result>
    #   And I press a search button
    #   Then I should see a <result>
    #   
    #   | search_word | author_name | forum_partition | sorting | ordering |showing_result  | result |
    #   | search_word | author_name | forum_partition | sorting | ordering |showing_result  | result |

  # Rails generates Delete links that use Javascript to pop up a confirmation
  # dialog and then do a HTTP POST request (emulated DELETE request).
  #
  # Capybara must use Culerity/Celerity or Selenium2 (webdriver) when pages rely
  # on Javascript events. Only Culerity/Celerity supports clicking on confirmation
  # dialogs.
  #
  # Since Culerity/Celerity and Selenium2 has some overhead, Cucumber-Rails will
  # detect the presence of Javascript behind Delete links and issue a DELETE request 
  # instead of a GET request.
  #
  # You can turn this emulation off by tagging your scenario with @no-js-emulation.
  # Turning on browser testing with @selenium, @culerity, @celerity or @javascript
  # will also turn off the emulation. (See the Capybara documentation for 
  # details about those tags). If any of the browser tags are present, Cucumber-Rails
  # will also turn off transactions and clean the database with DatabaseCleaner 
  # after the scenario has finished. This is to prevent data from leaking into 
  # the next scenario.
  #
  # Another way to avoid Cucumber-Rails' javascript emulation without using any
  # of the tags above is to modify your views to use <button> instead. You can
  # see how in http://github.com/jnicklas/capybara/issues#issue/12
  #

