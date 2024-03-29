require 'rails_helper'

RSpec.describe "Admin dashboard", type: :system do
  before do
    driven_by :rack_test
  end

  scenario "Is only available to admins" do
    user = create(:user)
    visit root_path
    expect(page).to_not have_content("Manage users")
    expect {
      visit admin_path
    }.to raise_exception(ActionController::RoutingError, "Not Found")

    login_as create(:reviewer)
    visit root_path
    expect(page).to_not have_content("Manage users")
    expect {
      visit admin_path
    }.to raise_exception(ActionController::RoutingError, "Not Found")
    expect {
      visit edit_user_path(user)
    }.to raise_exception(ActionController::RoutingError, "Not Found")

    login_as create(:editor)
    visit root_path
    expect(page).to_not have_content("Manage users")
    expect {
      visit admin_path
    }.to raise_exception(ActionController::RoutingError, "Not Found")
    expect {
      visit edit_user_path(user)
    }.to raise_exception(ActionController::RoutingError, "Not Found")

    login_as create(:admin)
    visit root_path
    expect(page).to have_content("Manage users")
    click_link("Manage users")
    expect(page).to have_current_path(admin_path)
    visit edit_user_path(user)
    expect(page).to have_current_path(edit_user_path(user))
  end

  describe "Search users" do
    before do
      user = create(:user, complete_name: "simple_user", github: "test1")
      reviewer = create(:reviewer, complete_name: "reviewer21_user", github: "rev21")
      editor = create(:editor, complete_name: "topiceditor_user", github: "astro")
      admin = create(:admin, complete_name: "admin_user", github: "admintest42")
      editor_admin = create(:admin, editor: true, complete_name: "eic_user", github: "owner33")

      login_as admin
      visit admin_path
    end

    scenario "initially lists all users" do
      expect(page).to have_content("simple_user")
      expect(page).to have_content("reviewer21_user")
      expect(page).to have_content("topiceditor_user")
      expect(page).to have_content("admin_user")
      expect(page).to have_content("eic_user")
    end

    scenario "by name" do
      fill_in "name", with: "topic"
      click_on "Find users"
      expect(page).to_not have_content("simple_user")
      expect(page).to_not have_content("reviewer21_user")
      expect(page).to have_content("topiceditor_user")
      expect(page).to_not have_content("admin_user")
      expect(page).to_not have_content("eic_user")
    end

    scenario "by github" do
      fill_in "name", with: "@test"
      click_on "Find users"
      expect(page).to have_content("simple_user")
      expect(page).to_not have_content("reviewer21_user")
      expect(page).to_not have_content("topiceditor_user")
      expect(page).to have_content("admin_user")
      expect(page).to_not have_content("eic_user")
    end

    scenario "filtering by role" do
      check "editor"
      click_on "Find users"
      expect(page).to_not have_content("simple_user")
      expect(page).to_not have_content("reviewer21_user")
      expect(page).to have_content("topiceditor_user")
      expect(page).to_not have_content("admin_user")
      expect(page).to have_content("eic_user")
    end

    scenario "filtering by multiple roles" do
      check "editor"
      check "admin"
      click_on "Find users"
      expect(page).to_not have_content("simple_user")
      expect(page).to_not have_content("reviewer21_user")
      expect(page).to_not have_content("topiceditor_user")
      expect(page).to_not have_content("admin_user")
      expect(page).to have_content("eic_user")
    end

    scenario "by name and roles" do
      fill_in "name", with: "astr"
      check "editor"
      click_on "Find users"
      expect(page).to_not have_content("simple_user")
      expect(page).to_not have_content("reviewer21_user")
      expect(page).to have_content("topiceditor_user")
      expect(page).to_not have_content("admin_user")
      expect(page).to_not have_content("eic_user")

      fill_in "name", with: "astr"
      check "reviewer"
      check "editor"
      click_on "Find users"

      expect(page).to have_content("No users found")
    end
  end

  describe "Edit user" do
    before do
      @user = create(:user, complete_name: "Tester McTest", github: "test33")
      login_as create(:admin)
      visit admin_path
      click_link "Tester McTest"
      expect(page).to have_current_path(user_path(@user))
    end

    scenario "show user roles" do
      within("#roles") do
        expect(page).to_not have_content("Reviewer")
        expect(page).to_not have_content("Editor")
        expect(page).to_not have_content("Admin")
      end
    end

    scenario "change roles" do
      within("#roles") do
        expect(page).to_not have_content("Reviewer")
        expect(page).to_not have_content("Editor")
        expect(page).to_not have_content("Admin")
      end
      expect(page).to have_link("Grant reviewer status")
      expect(page).to have_link("Grant editor status")
      expect(page).to have_link("Grant admin status")

      click_link "Grant reviewer status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to have_content("Reviewer")
        expect(page).to_not have_content("Editor")
        expect(page).to_not have_content("Admin")
      end
      expect(page).to have_link("Remove reviewer status")
      expect(page).to have_link("Grant editor status")
      expect(page).to have_link("Grant admin status")

      click_link "Grant editor status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to have_content("Reviewer")
        expect(page).to have_content("Editor")
        expect(page).to_not have_content("Admin")
      end
      expect(page).to have_link("Remove reviewer status")
      expect(page).to have_link("Remove editor status")
      expect(page).to have_link("Grant admin status")

      click_link "Grant admin status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to have_content("Reviewer")
        expect(page).to have_content("Editor")
        expect(page).to have_content("Admin")
      end
      expect(page).to have_link("Remove reviewer status")
      expect(page).to have_link("Remove editor status")
      expect(page).to have_link("Remove admin status")

      click_link "Remove reviewer status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to_not have_content("Reviewer")
        expect(page).to have_content("Editor")
        expect(page).to have_content("Admin")
      end
      expect(page).to have_link("Grant reviewer status")
      expect(page).to have_link("Remove editor status")
      expect(page).to have_link("Remove admin status")

      click_link "Remove editor status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to_not have_content("Reviewer")
        expect(page).to_not have_content("Editor")
        expect(page).to have_content("Admin")
      end
      expect(page).to have_link("Grant reviewer status")
      expect(page).to have_link("Grant editor status")
      expect(page).to have_link("Remove admin status")

      click_link "Remove admin status"

      expect(page).to have_content("User status updated!")
      within("#roles") do
        expect(page).to_not have_content("Reviewer")
        expect(page).to_not have_content("Editor")
        expect(page).to_not have_content("Admin")
      end
      expect(page).to have_link("Grant reviewer status")
      expect(page).to have_link("Grant editor status")
      expect(page).to have_link("Grant admin status")
    end

    scenario "update profile data" do
      expect(page).to have_content("Tester McTest")
      expect(page).to have_content("GitHub: test33")
      create(:language, name: "Julia")
      create(:language, name: "Python")
      create(:area, name: "Astronomy")
      create(:area, name: "Plant Science")

      click_link "Edit"
      expect(page).to have_current_path(edit_user_path(@user))
      expect(page).to have_content("Tester McTest")

      fill_in "user_github", with: "NewHandle"
      fill_in "user_complete_name", with: "Tester Reviewer"
      fill_in "user_citation_name", with: "Reviewer., T."
      fill_in "user_email", with: "tester@teste.rs"
      fill_in "user_affiliation", with: "Reviewing University"
      fill_in "user_url", with: "http://testing.revs/reviewer33"
      fill_in "user_description", with: "Head of plant division"
      check("Plant Science")
      fill_in "user_domains", with: "Trees, Forests"
      check("Julia")
      expect {
        click_button "Update user profile"
      }.to_not change { User.count }

      expect(page).to have_content("User data updated!")

      visit user_path(@user)
      expect(page).to_not have_content("Tester McTest")
      expect(page).to_not have_content("GitHub: test33")

      expect(page).to have_content("GitHub: NewHandle")
      expect(page).to have_content("Name: Tester Reviewer")
      expect(page).to have_content("Citation name: Reviewer., T.")
      expect(page).to have_content("Email: tester@teste.rs")
      expect(page).to have_content("Affiliation:\nReviewing University")
      expect(page).to have_content("URL:\nhttp://testing.revs/reviewer33")
      expect(page).to have_content("Description:\nHead of plant division")
      expect(page).to have_content("Area(s) of expertise:\nPlant Science")
      expect(page).to have_content("Domains:\nTrees, Forests")
      expect(page).to have_content("Programming languages:\nJulia")
    end

    scenario "delete feedback" do
      editor = create(:editor)
      feedback = create(:feedback, user: @user, editor: editor, rating: "positive", comment: "A very nice comment")

      visit user_path(@user)

      within("#feedback-#{feedback.id}") do
        expect(page).to have_content("A very nice comment")
        expect(page).to have_content("Delete")
        click_link "Delete"
      end

      expect(page).to have_content("Feedback deleted")
      expect(page).to_not have_content("A very nice comment")

      visit user_path(@user)
      expect(page).to have_content("There's no feedback for this reviewer yet.")
    end
  end

  describe "Show user page" do
    before do
      @reviewer = create(:reviewer,
                     complete_name: "Tester McTest",
                     citation_name: "McTest, T.",
                     email: "test@testers.test",
                     affiliation: "Research test center",
                     github: "tester-reviewer-33",
                     domains: "big trees",
                     orcid: "1111-2222-3333-4444",
                     url: "https://mctesterweb.site",
                     description: "I have a PhD on plants"
                    )
      @reviewer.languages << create(:language, name: "Python")
      @reviewer.languages << create(:language, name: "Julia")
      @reviewer.areas << create(:area, name: "Plant Science")
    end

    scenario "is not public" do
      expect {
        visit user_path(@reviewer)
      }.to raise_exception(ActionController::RoutingError, "Not Found")
    end

    scenario "is not available to non-admins" do
      login_as create(:reviewer)
      expect {
        visit user_path(@reviewer)
      }.to raise_exception(ActionController::RoutingError, "Not Found")

      logout

      login_as create(:editor)
      expect {
        visit user_path(@reviewer)
      }.to raise_exception(ActionController::RoutingError, "Not Found")
    end

    scenario "is available to Admins" do
      login_as create(:admin)

      visit user_path(@reviewer)

      expect(page).to have_content("tester-reviewer-33")
      expect(page).to have_content("Tester McTest")
      expect(page).to have_current_path(user_path(@reviewer))
    end

    scenario "shows reviewer's profile info" do
      login_as create(:admin)

      visit user_path(@reviewer)

      expect(page).to have_content("Tester McTest")
      expect(page).to have_content("GitHub: tester-reviewer-33")
      expect(page).to have_content("ORCID: 1111-2222-3333-4444")
      expect(page).to have_content("test@testers.test")
      expect(page).to have_content("Research test center")
      expect(page).to have_content("big trees")
      expect(page).to have_content("Plant Science")
      expect(page).to have_content("Python")
      expect(page).to have_content("Julia")
      expect(page).to have_content("https://mctesterweb.site")
      expect(page).to have_content("I have a PhD on plants")
      expect(page).to have_content(@reviewer.created_at.strftime("%d-%m-%Y at %H:%M:%S %Z"))
      expect(page).to have_content(@reviewer.created_at.strftime("%d-%m-%Y at %H:%M:%S %Z"))
    end
  end
end
