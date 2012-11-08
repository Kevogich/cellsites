Feature: Superadmin Session
  In order manage the app
  As a visitor
  I want to login myself in the app

Background:
  Given the following roles exist:
    |name|identifier|
    |Superadmin|superadmin|
    |Admin|admin|
  And the following companies exist:
    |name|contact_person|admin_username|admin_password|email|
    |Test Company|Test Admin|testadmin|password|test@company.com|

Scenario: Sign In and Sign Out
  Given I am on the users sign in page
  Then I should see "Login"
  And I should see "Password"
  When I fill in "user_login" with "testadmin"
  And I fill in "user_password" with "password"
  And I press "Sign in"
  Then I should be on the admin home page
  And I should see "Test Company Admin"

  When I follow "Logout"
  Then I should be on the users sign in page

