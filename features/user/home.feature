Feature: User Homepage
  In order use the app
  As a user
  I want to see my homepage

Background:
  Given the following users exist:
    |name|email           |username|password|
    |Test|test@example.com|test    |password|
  And I am logged in as "test" using password "password"

Scenario: User Homepage
  When I go to the home page
  Then I should see "Welcome!"

