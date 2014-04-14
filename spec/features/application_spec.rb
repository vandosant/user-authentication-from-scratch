require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'User can register' do
    visit '/'

    click_link "Register"
    fill_in "email_address", with: "joe@example.com"
    fill_in "password", with: "password"
    click_on "Register"
    expect(page).to have_content("Hello joe@example.com")

  end
end