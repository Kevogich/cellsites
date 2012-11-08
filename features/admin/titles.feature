Feature: admin Session
  In order manage the app
  As a visitor
  I want to login myself in the app

Background:
  Given the following roles exist:
    |name|identifier|
    |Admin|admin|
  And the following companies exist:
    |name|contact_person|admin_username|admin_password|email|
    |Test Company|Test Admin|testadmin|password|test@company.com|
  And I am logged in as "testadmin" using password "password"
  And I follow "Roles"

Scenario: Add Title
  Given I am on the admin roles page
  Then I should see "Add Title"
  
  When I follow "Add Title"
  Then I should see "Add Title Name"
  
  When I fill in "title_name" with "Test"
  And I press "Create Title"
  Then I should see "Test" within "table#titles_list" 

When I follow "Delete"
