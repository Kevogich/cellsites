Feature: Superadmin Companies management
  In order manage the app
  As a superadmin
  I want to manage companies

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
  And I am logged in as "admin" using password "password"


Scenario: Superadmin Create Company
  When I go to the superadmin home page
  And I follow "Companies"
  Then I should be on the superadmin companies page
  When I follow "Add Company"
  And I fill in the following:
    |company_name|Test Company|
    |company_admin_username|testadmin|
    |company_admin_password|password|
    |company_email|test@company.com| 
    |company_contact_person|Test Admin|
  And I press "Create Company"
  Then I should see "Company has been created"
  And I should see "Test Company" within "table#companies_list"

