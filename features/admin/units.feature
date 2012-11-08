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

@current-deepak @javascript
Scenario: Add Unit
  Given I am on the admin roles page
  Then I should see "Add Unit"
  
  When I follow "Add Unit"
  Then I should see "Add Unit Name"
  
  When I fill in "unit_name" with "Test"
  And I press "Create Unit"
  Then I should see "Test" within "table#units_list" 

