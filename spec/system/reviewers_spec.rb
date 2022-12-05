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
                     twitter: "tester-tw",
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

    scenario "shows reviewer's profile info" do
      login_as create(:editor)

      visit reviewer_path(@reviewer)

      expect(page).to have_content("Tester McTest")
      expect(page).to have_content("GitHub: tester-reviewer-33")
      expect(page).to have_content("Orcid: 1111-2222-3333-4444")
      expect(page).to have_content("test@testers.test")
      expect(page).to have_content("Research test center")
      expect(page).to have_content("big trees")
      expect(page).to have_content("tester-tw")
      expect(page).to have_content("Plant Science")
      expect(page).to have_content("Python")
      expect(page).to have_content("Julia")
      expect(page).to have_content("https://mctesterweb.site")
      expect(page).to have_content("I have a PhD on plants")

      expect(page).to have_content("Active reviews: 0")
      expect(page).to have_content("Reviews all time: 0")
      expect(page).to have_content("Last review on: No info")
    end

    scenario "shows reviewer stats" do
      login_as create(:editor)

      stats = @reviewer.stat
      stats.active_reviews = 12
      stats.reviews_all_time = 33
      stats.reviews_url = "https://all.reviews/tester-reviewer-33"
      stats.active_reviews_url = "https://active.reviews/tester-reviewer-33"
      stats.last_review_on = Date.parse("31/1/2022")
      stats.save!

      visit reviewer_path(@reviewer)
      expect(page).to have_link("Active reviews: 12", href: "https://active.reviews/tester-reviewer-33")
      expect(page).to have_link("Reviews all time: 33", href: "https://all.reviews/tester-reviewer-33")
      expect(page).to have_content("Last review on: 31-01-2022")
    end
  end
end
