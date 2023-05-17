require 'rails_helper'

RSpec.describe "Reviewers", type: :system do
  before do
    driven_by :rack_test
  end

  describe "Show page" do
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
      visit reviewer_path(@reviewer)

      expect(page).to_not have_content("tester-reviewer-33")
      expect(page).to_not have_content("Tester McTest")
      expect(page).to have_current_path(root_path)
    end

    scenario "is available to Editors" do
      login_as create(:editor)

      visit reviewer_path(@reviewer)

      expect(page).to have_content("tester-reviewer-33")
      expect(page).to have_content("Tester McTest")
      expect(page).to have_current_path(reviewer_path(@reviewer))
    end

    scenario "shows reviewer's profile info to editors" do
      login_as create(:editor)

      visit reviewer_path(@reviewer)

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

      expect(page).to have_content("Active reviews: 0")
      expect(page).to have_content("Reviews all time: 0")
      expect(page).to have_content("Last review on: No info")

      expect(page).to have_content("Feedback")
    end

    scenario "shows reviewer stats to editors" do
      login_as create(:editor)

      stats = @reviewer.stat
      stats.active_reviews = 12
      stats.reviews_all_time = 33
      stats.last_review_on = Date.parse("31/1/2022")
      stats.save!

      visit reviewer_path(@reviewer)
      expect(page).to have_link("Active reviews: 12", href: "https://test.journ.al/active_reviews/tester-reviewer-33")
      expect(page).to have_link("Reviews all time: 33", href: "https://test.journ.al/papers/reviewed_by/tester-reviewer-33")
      expect(page).to have_content("Last review on: 31-01-2022")
    end

    scenario "is available to logged in users" do
      login_as create(:user)

      visit reviewer_path(@reviewer)

      expect(page).to have_content("tester-reviewer-33")
      expect(page).to have_content("Tester McTest")
      expect(page).to have_current_path(reviewer_path(@reviewer))
    end

    scenario "shows reviewer's limited profile info to users" do
      login_as create(:user)

      visit reviewer_path(@reviewer)

      expect(page).to have_content("Tester McTest")
      expect(page).to have_content("GitHub: tester-reviewer-33")
      expect(page).to have_content("ORCID: 1111-2222-3333-4444")
      expect(page).to_not have_content("test@testers.test")
      expect(page).to have_content("Research test center")
      expect(page).to have_content("big trees")
      expect(page).to have_content("Plant Science")
      expect(page).to have_content("Python")
      expect(page).to have_content("Julia")
      expect(page).to have_content("https://mctesterweb.site")
      expect(page).to have_content("I have a PhD on plants")

      expect(page).to_not have_content("Active reviews: 0")
      expect(page).to_not have_content("Reviews all time: 0")
      expect(page).to_not have_content("Last review on: No info")

      expect(response).to_not have_content("Feedback")
    end

    scenario "shows if a reviewer is an editor" do
      visit reviewer_path(@reviewer)
      expect(page).to_not have_content("Editor")

      login_as create(:editor)
      visit reviewer_path(@reviewer)
      expect(page).to_not have_content("Editor")

      @reviewer.editor = true
      @reviewer.save

      visit reviewer_path(@reviewer)
      expect(page).to have_content("Editor")
    end
  end

  describe "Adding a reviewer" do
    scenario "is not available for non-editors" do
      login_as create(:user)

      visit new_reviewer_path
      expect(page).to have_current_path(root_path)
      expect(page).to_not have_content("Add new reviewer")
    end

    describe "by an editor" do
      before do
        create(:language, name: "Julia")
        create(:language, name: "Python")
        create(:language, name: "Ruby")
        create(:area, name: "Astronomy")
        create(:area, name: "Biomedicine")
        create(:area, name: "Plant Science")

        login_as create(:editor)
        visit new_reviewer_path
        expect(page).to have_content("Add new reviewer")

        expect(find_field("Julia")).to_not be_checked
        expect(find_field("Python")).to_not be_checked
        expect(find_field("Ruby")).to_not be_checked
        expect(find_field("Astronomy")).to_not be_checked
        expect(find_field("Biomedicine")).to_not be_checked
        expect(find_field("Plant Science")).to_not be_checked
      end

      scenario "GitHub username is mandatory" do
        expect {
          click_button "Create reviewer profile"
        }.to_not change { User.count }
        expect(page).to have_content("1 error, prohibited to create the reviewer:")
        expect(page).to have_content("Github: can't be blank")
      end

      scenario "is not possible if user already exists" do
        create(:reviewer, github: "tester99")

        fill_in "user_github", with: "tester99"
        expect {
          click_button "Create reviewer profile"
        }.to_not change { User.count }
        expect(page).to have_content("The reviewer with the GitHub username tester99 is already registered in the system.")
        expect(page).to have_link("reviewers search", href: search_reviewers_path(name: "tester99"))
      end

      scenario "creates a new reviewer" do
        fill_in "user_github", with: "testerGHhandle"
        fill_in "user_complete_name", with: "Tester R. Spec"
        fill_in "user_citation_name", with: "R, T."
        fill_in "user_email", with: "tester@teste.ers"
        fill_in "user_affiliation", with: "Testing University"
        fill_in "user_url", with: "http://testing.revs/tester"
        check("Plant Science")
        fill_in "user_domains", with: "Rainforest, Forests"
        check("Julia")
        check("Ruby")
        expect {
          click_button "Create reviewer profile"
        }.to change { User.reviewers.count }.by(1)

        expect(page).to have_content("Reviewer added!")

        visit search_reviewers_path(name: "testerGHhandle")
        click_link "Tester R. Spec"

        expect(page).to have_content("GitHub: testerGHhandle")
        expect(page).to have_content("Name: Tester R. Spec")
        expect(page).to have_content("Citation name: R, T.")
        expect(page).to have_content("Email: tester@teste.ers")
        expect(page).to have_content("Affiliation:\nTesting University")
        expect(page).to have_content("URL:\nhttp://testing.revs/tester")
        expect(page).to have_content("Area(s) of expertise:\nPlant Science")
        expect(page).to have_content("Domains:\nRainforest, Forests")
        expect(page).to have_content("Programming languages:\nJulia, Ruby")
      end
    end
  end
end
