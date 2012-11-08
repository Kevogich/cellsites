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

@current @javascript
Scenario: Add Group
  Given I am on the admin roles page
  Then I should see "Add Group"
  
  When I follow "Add Group"
  Then I should see "Add Group Name"
  
  When I fill in "group_name" with "Test" within "#colorbox"
  And I press "Create Group"
  Then I should see "Test" within "table#groups_list"

  #Given I expect to click "OK" on a confirmation box saying "Are you sure?"
  When I follow "delete" within "table#groups_list"
  And a confirmation box saying "Are you sure?" should pop up
  And I want to click "OK"
  #Then I should not see "Test" within "table#groups_list" 
