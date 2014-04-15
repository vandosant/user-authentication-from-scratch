require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'User can register and logout' do
    visit '/'

    expect(page).to have_no_content("Logout")
    expect(page).to have_no_content("Welcome,")

    click_link "Register"
    fill_in "email_address", with: "joe@example.com"
    fill_in "password", with: "password"
    click_on "Register"

    expect(page).to have_content("Welcome, joe@example.com")
    expect(page).to have_no_content("You are not logged in")
    expect(page).to have_no_content("Register")

    click_link "Logout"

    expect(page).to have_no_content("Welcome, joe@example.com")
  end
end