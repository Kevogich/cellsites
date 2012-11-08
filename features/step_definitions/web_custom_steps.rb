When /^(?:|I )accept the confirmation$/ do
 a = page.driver.switch_to.alert
 a.accept
end

Given /^I expect to click "([^"]*)" on a confirmation box saying "([^"]*)"$/ do |option, message|
  retval = (option == "OK") ? "true" : "false"

  page.evaluate_script("window.confirm = function (msg) {
   $.cookie('confirm_message', msg)
   return #{retval}
  }")

 @expected_message = message
end

Then /^the confirmation box should have been displayed$/ do
  page.evaluate_script("$.cookie('confirm_message')").should_not be_nil
  page.evaluate_script("$.cookie('confirm_message')").should eq(@expected_message)
  page.evaluate_script("$.cookie('confirm_message', null)")
end

Given /^a confirmation box saying "([^"]*)" should pop up$/ do |message|
    @expected_message = message
end

Given /^I want to click "([^"]*)"$/ do |option|
  retval = (option == "OK") ? "true" : "false"

  page.evaluate_script("window.confirm = function (msg) {
                        $.cookie('confirm_message', msg)
                        return #{retval}
                      }")
end

Then /^the confirmation box should have been displayed$/ do
    page.evaluate_script("$.cookie('confirm_message')").should_not be_nil
      page.evaluate_script("$.cookie('confirm_message')").should eq(@expected_message)
        page.evaluate_script("$.cookie('confirm_message', null)")
end

