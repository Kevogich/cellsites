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
  And I follow "Users"

Scenario: Add User
  Given I am on the admin company_users page
  Then I should see "Add User"
  
  When I follow "Add User"
  And I fill in the following:
    |company_user_user_attributes_name|Test|
    |company_user_user_attributes_email|test@test.com|
    |company_user_user_attributes_username|test|
    |company_user_user_attributes_password|password|
    |company_user_user_attributes_password_confirmation|password|
  And I press "Create Company user"
  Then I should see "User has been created"

  #Given I expect to click "OK" on a confirmation box saying "Are you sure?"
  #When I follow "delete" within "table#groups_list"
  #Then I should not see "Test" within "table#groups_list" 
