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
    scenario "can log out" do
      login_as(create(:user))
      visit root_path
      expect(page).to_not have_button("Log in with GitHub")

      logout
      click_link("Log out")
      expect(page).to have_content("Signed out!")
      expect(page).to have_button("Log in with GitHub")
    end

    scenario "are saluted with GihHub handle if name is missing" do
      user = create(:user, complete_name: "Revie W. Er", github: "test_user")
      login_as(user)
      visit root_path
      expect(page).to have_content("Hi Revie W. Er")
      expect(page).to_not have_content("Hi @test_user")

      user.update_attribute(:complete_name, "")
      visit root_path
      expect(page).to_not have_content("Hi Revie W. Er")
      expect(page).to have_content("Hi @test_user")
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

  describe "for reviewers" do
    scenario "prompt user to complete profile in missing info" do
      reviewer = create(:reviewer, complete_name: nil, areas: [])
      login_as reviewer
      visit root_path

      expect(page).to have_content("Please complete your profile")
    end

    scenario "list info if reviewer's profile is complete" do

    end
  end
end
