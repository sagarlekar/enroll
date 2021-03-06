require 'watir'
# load Rails.root + "db/seeds.rb"

Before "@watir" do
  @browser = Watir::Browser.new :chrome
end

After "@watir" do
 # @browser.close
end

Given(/^I do not exist as a user$/) do
end

Given(/^I have an existing employee record$/) do
end

Given(/^I have an existing person record$/) do
end

When(/^I go to the employee account creation page$/) do
  @browser.goto("http://localhost:3000/")
  Watir::Wait.until(30) { @browser.a(:text => "Employee Portal").present? }
  sleep(1)
  @browser.a(:text => "Employee Portal").click
  Watir::Wait.until(30) { @browser.a(:text => "Create account").present? }
  sleep(1)
  @browser.a(:text => "Create account").click
end

When(/^I enter my new account information$/) do
  Watir::Wait.until(30) { @browser.text_field(:name => "user[password_confirmation]").present? }
  @browser.text_field(:name => "user[email]").set("trey.evans#{rand(100)}@dc.gov")
  @browser.text_field(:name => "user[password]").set("12345678")
  @browser.text_field(:name => "user[password_confirmation]").set("12345678")
  @browser.input(:value => "Create account").click
end

Then(/^I should be logged in$/) do
  Watir::Wait.until(30) { @browser.element(:text => /Welcome! You have signed up successfully./).present? }
  expect(@browser.element(:text => /Welcome! You have signed up successfully./).visible?).to be_truthy
end

When(/^I go to register as an employee$/) do
  expect(@browser.a(:text => "Continue").visible?).to be_truthy
  @browser.a(:text => "Continue").click
end

Then(/^I should see the employee search page$/) do
  Watir::Wait.until { @browser.text_field(:name => "person[first_name]").present? }
  expect(@browser.text_field(:name => "person[first_name]").visible?).to be_truthy
end

When(/^I enter the identifying info of my existing person$/) do
  @browser.text_field(:name => "person[first_name]").set("Jonathan")
  @browser.text_field(:name => "person[last_name]").set("Hall")
  @browser.text_field(:name => "person[date_of_birth]").set("10/12/1983")
  @browser.p(:text=> /Personal Information/).click
  @browser.text_field(:name => "person[ssn]").set("722991234")
  sleep(2)
  @browser.input(:value => "Search Employers", :type => "submit").click
  sleep(3)
end

Then(/^I should see the matched employee record form$/) do
  expect(@browser.dd(:text => /Acme Inc\./).visible?).to be_truthy
  @browser.input(:value => /This is my employer/).click
  sleep(5)
end

When(/^I complete the matched employee form$/) do
  @browser.text_field(:name => "person[phones_attributes][0][full_phone_number]").set("5555555555")
  @browser.text_field(:name => "person[emails_attributes][0][address]").set("jhall@gmail.com")
  @browser.text_field(:name => "person[emails_attributes][1][address]").click
  @browser.input(:id => "continue-employer").click
  sleep(5)
end

Then(/^I should see the dependents page$/) do
  expect(@browser.p(:text => /Household Information/).visible?).to be_truthy
end

When(/^I click continue on the dependents page$/) do
  @browser.a(:text => "Continue", :href => /consumer\/employee_dependents\/group_selection/).click
  sleep(5)
end

Then(/^I should see the group selection page$/) do
  Watir::Wait.until(30) { @browser.a(:text => "Continue", :href => /people\/select_plan/).present? }
  sleep(1)
end

When(/^I click continue on the group selection page$/) do
  @browser.a(:text => "Continue", :href => /people\/select_plan/).click
  sleep(5)
end

Then(/^I should see the plan shopping page$/) do
  expect(@browser.p(:text => /Select a Plan/).visible?).to be_truthy
end

When(/^I select a plan on the plan shopping page$/) do
    @browser.a(:text => "Continue").click
    sleep(2)
    @browser.a(:text => "Select").click
    sleep(5)
end

Then(/^I should see the coverage summary page$/) do
   expect(@browser.p(:text => /Your monthly total family premium/).visible?).to be_truthy
end

When(/^I confirm on the coverage summary page$/) do
   @browser.a(:text => "Continue").click
   sleep(5)
end

Then(/^I should see the "my account" page$/) do
  expect(@browser.span(:text => "Household").visible?).to be_truthy
end
