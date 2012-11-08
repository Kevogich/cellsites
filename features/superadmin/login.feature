Feature: Superadmin Session
  In order manage the app
  As a visitor
  I want to login myself in the app

Background:
  Given the following users exist:
    |name|email|username|password|
    |Admin|admin@example.com|admin|password|
  And the following roles exist:
    |name|identifier|
    |Superadmin|superadmin|
    |Admin|admin|
  And the users have following roles:
    |username|roles|
    |admin|superadmin|

Scenario: Sign In and Sign Out
  Given I am on the users sign in page
  Then I should see "Login"
  And I should see "Password"
  When I fill in "user_login" with "admin"
  And I fill in "user_password" with "password"
  And I press "Sign in"
  Then I should be on the superadmin home page
  And I should see "RaoTechAdmin"

  When I follow "Logout"
  Then I should be on the users sign in page

