require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  before do
    DB[:users].insert(:email => "admin@example.com", :password => BCrypt::Password.create("password"), :admin => true)
  end

  after do
    DB[:users].where(:email => "admin@example.com").delete
  end

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

  scenario 'User can login again after logout' do
    visit '/'

    click_link "Register"
    fill_in "email_address", with: "joe@example.com"
    fill_in "password", with: "password"
    click_on "Register"
    click_link "Logout"

    click_link "Login"
    fill_in "email_address", with: "joe@example.com"
    fill_in "password", with: "password"
    click_on "Login"

    expect(page).to have_content("Welcome, joe@example.com")

  end

  scenario 'User cannot login with incorrect password' do
    visit '/'

    click_link "Register"
    fill_in "email_address", with: "gus@example.com"
    fill_in "password", with: "password"
    click_on "Register"

    click_on "Logout"

    click_link "Login"
    fill_in "email_address", with: "gus@example.com"
    fill_in "password", with: "oiadjfoaidj"
    click_on "Login"
    expect(page).to have_no_content("Welcome, gus@example.com")
    expect(page).to have_content("Email / password is invalid")
  end

  scenario 'User cannot login with invalid email' do
    visit '/'

    click_link "Register"
    fill_in "email_address", with: "gus@example.com"
    fill_in "password", with: "password"
    click_on "Register"

    click_on "Logout"

    click_link "Login"
    fill_in "email_address", with: "gusking@example"
    fill_in "password", with: "password"
    click_on "Login"
    expect(page).to have_content("Email / password is invalid")

  end

  scenario 'New users are not administrators by default' do
    visit '/'

    click_link "Register"
    fill_in "email_address", with: "chuck@example.com"
    fill_in "password", with: "password"
    click_on "Register"

    actual = DB[:users].where(:email => "chuck@example.com").to_a.first[:admin]

    expect(actual).to eq false
  end

  scenario 'Administrators can view all other users' do
    visit '/'
    expect(page).to have_no_content ("View all users")
    click_link "Login"
    fill_in "email_address", with: "admin@example.com"
    fill_in "password", with: "password"
    click_on "Login"

    click_link "View all users"

    expect(page).to have_content("ID")
    expect(page).to have_content("Users")
    expect(page).to have_content("welcome, admin@example.com")
    expect(page).to have_link("logout")
    expect(page).to have_link("Home")

  end

  scenario 'Users can visit the about page' do
    visit '/'

    click_link "About"

    expect(page).to have_content("About")
  end

  scenario 'Administrators can view the statistics page' do
    visit '/'
    expect(page).to have_no_content ("View all users")
    click_link "Login"
    fill_in "email_address", with: "admin@example.com"
    fill_in "password", with: "password"
    click_on "Login"

    click_link "View statistics"

    expect(page).to have_content("Stats")
    expect(page).to have_content("Beer Histogram")
    expect(page).to have_content("welcome, admin@example.com")
    expect(page).to have_link("logout")
    expect(page).to have_link("Home")
  end
end