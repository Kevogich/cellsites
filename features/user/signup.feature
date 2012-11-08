Feature: User Session
  In order use the app
  As a visitor
  I want to register and login myself in the app

Scenario: Redirect visitor to sign in page
  Given I am a visitor
  When I go to the home page
  Then I should be on the users sign in page

Scenario: Sign In and Sign Out
  Given I am on the users sign in page
  Then I should see "Login"
  And I should see "Password"
  #And I should see "Sign up"

  Given the following users exists:
    |name|email           |username|password|
    |Test|test@example.com|test    |password|
  Given an user exists
  When I fill in "user_login" with "test"
  And I fill in "user_password" with "password"
  And I press "Sign in"
  Then I should be on the home page
  And I should see "Test"

  When I follow "Logout"
  Then I should be on the users sign in page

#Scenario: Sign up
#  Given I am on the users sign in page
#  And I follow "Sign up"
#  Then I should be on the users sign up page
#  And I should see "Sign up"
#
#  When I fill in the following:
#    |user_email                |test2@example.com|
#    |user_password             |password         |
#    |user_password_confirmation|password         |
#  And I press "Sign up"
#  Then I should be on the home page

#Scenario Outline: Sign up validations
#  Given I am on users sign up page
#  When I fill in the following:
#    |user_email                |<email>                |
#    |user_password             |<password>             |
#    |user_password_confirmation|<password_confirmation>|
#  And I press "Sign up"
#  And I should see "<error>"
#
#  Examples:
#    |email           |password|password_confirmation|error                     |
#    |test@example.com|password|password2            |doesn't match confirmation|
