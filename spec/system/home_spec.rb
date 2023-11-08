require 'rails_helper'

RSpec.describe "Home", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario "Includes only links to login using GitHub OAuth and to sign up" do
    visit root_path
    expect(page).to have_button("Log in with GitHub")
    expect(page).to have_link("sign up", href: reviewer_signup_path)
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

  describe "/lookup" do
    scenario "prompts users to sign up skipping marking them as reviewers" do
      visit no_reviewer_signup_path
      expect(page).to have_selector("form.button_to[@action='/auth/github?reviewer=no']")

      within("form.button_to[@action='/auth/github?reviewer=no']") do
        expect(page).to have_button("Log in with your GitHub user")
      end
      expect(page).to have_content("help find potential reviewers")
      expect(page).to_not have_link("Log out")
    end

    scenario "redirects to home if user is already logged in" do
      login_as(create(:user))
      visit no_reviewer_signup_path
      expect(page).to have_current_path(reviewers_path)
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
      reviewer = create(:reviewer, complete_name: "Vera", email: "vera@rub.in", affiliation: "Georgetown", areas: [create(:area, name: "Astronomy")], domains: "galaxies,dark matter" )
      login_as reviewer
      visit root_path

      expect(page).to have_content("You are listed as reviewer for")
      expect(page).to have_content("Astronomy")
      expect(page).to have_content("with expertise in galaxies and dark matter")
      expect(page).to_not have_content("Please complete your profile")
    end
  end

  describe "for editors" do
    scenario "list available actions" do
      editor = create(:editor, complete_name: nil, areas: [])
      login_as editor
      visit root_path

      expect(page).to have_content("As a member of the editors team you can:")
      expect(page).to have_link("Search for reviewers")
      expect(page).to have_content("Provide feedback on reviewers")
      expect(page).to have_link("Add a new reviewer to the database")

      expect(page).to have_content("Your are currently not available to review.")
      expect(page).to_not have_content("You are also listed as reviewer for")
    end

    scenario "list reviewer's info" do
      editor = create(:editor, reviewer: true, complete_name: "Vera", email: "vera@rub.in", affiliation: "Georgetown", areas: [create(:area, name: "Astronomy")], domains: "galaxies,dark matter" )
      login_as editor
      visit root_path

      expect(page).to_not have_content("Your are currently not available to review.")
      expect(page).to have_content("You are also listed as reviewer for")
      expect(page).to have_content("Astronomy")
      expect(page).to have_content("with expertise in galaxies and dark matter")
    end
  end

  describe "for no reviewers" do
    scenario "allow users to mark themselves as available to review" do
      no_reviewer = create(:user)
      login_as no_reviewer
      visit root_path

      expect(page).to have_content("Your current status is: not available to review.")
      expect(page).to have_button("Mark me as available to review")
      expect(page).to_not have_content("Please complete your profile")

      click_button("Mark me as available to review")

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Your profile was successfully updated.")
      expect(page).to have_content("Thanks for signing up as a reviewer!")
      expect(page).to_not have_content("Your current status is: not available to review.")
    end
  end
end
