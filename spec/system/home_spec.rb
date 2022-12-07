require 'rails_helper'

RSpec.describe "Home", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario "Includes only a link to login using GitHub OAuth" do
    visit root_path
    expect(page).to have_button("Log in with GitHub")
    expect(page).to_not have_link("Log out")
  end

  describe "Logged in users" do
    scenario "Can log out" do
      login_as(create(:user))
      visit root_path
      expect(page).to_not have_button("Log in with GitHub")

      logout
      click_link("Log out")
      expect(page).to have_content("Signed out!")
      expect(page).to have_button("Log in with GitHub")
    end
  end

  describe "/join" do
    scenario "prompts user to sign up as reviewer" do
      visit reviewer_signup_path
      expect(page).to have_button("Log in with your GitHub user")
      expect(page).to have_content("reviewer sign up")
      expect(page).to have_content("complete your profile information")
      expect(page).to_not have_link("Log out")
    end

    scenario "redirects to home if user is already logged in" do
      login_as(create(:user))
      visit reviewer_signup_path
      expect(page).to have_current_path(root_path)
    end
  end
end
