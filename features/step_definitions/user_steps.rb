Given /^I am a visitor$/ do
  #do nothing
end

Given /^I am logged in as "([^"]*)" using password "([^"]*)"$/ do |login, password|
  visit '/users/sign_in'
  fill_in "user_login", :with => login
  fill_in "user_password", :with => password
  click_button "Sign in"
end

When /^I log\s?out$/ do
  click_link 'Logout'
end

Given /^the users have following roles:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_username( hash['username'] )
    hash['roles'].split(',').each do |role_name|
      user.roles << Role.find_by_identifier( role_name )
    end
  end
end
