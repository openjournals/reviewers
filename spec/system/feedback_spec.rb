require 'rails_helper'

RSpec.describe "Feedback", type: :system do
  before do
    driven_by :rack_test
  end

  before do
    @user = create(:user,
                  complete_name: "Tester McTest",
                  citation_name: "McTest, T.",
                  email: "test@testers.test",
                  affiliation: "Research test center",
                  github: "tester-user-33",
                  domains: "big trees"
                  )

    @user.languages << create(:language, name: "Python")
    @user.areas << create(:area, name: "Plant Science")
  end

  scenario "Is only available to editors" do
    visit reviewer_path(@user)
    expect(page).to have_current_path(root_path)
    expect(page).to_not have_content(@user.complete_name)


    login_as @user
    visit reviewer_path(@user)
    expect(page).to have_current_path(reviewer_path(@user))
    expect(page).to_not have_content(@user.email)
    expect(page).to_not have_content("Active reviews")
    expect(page).to_not have_css("#feedback-from-editors")
    expect(page).to_not have_content("Feedback")

    login_as create(:editor)
    visit reviewer_path(@user)
    expect(page).to have_current_path(reviewer_path(@user))
    expect(page).to have_content(@user.complete_name)
    expect(page).to have_content("Active reviews")
    expect(page).to have_css("#feedback-from-editors")
    expect(page).to have_content("Feedback")
  end

  describe "Editors" do
    before do
      @editor = create(:editor)
      @feedback = create(:feedback, user: @user, editor: @editor, comment: "A comment")

      login_as @editor
      visit reviewer_path(@user)
    end

    scenario "can add feedback" do
      expect(page).to have_content("A comment")

      find("#add-feedback-link").click
      fill_in "feedback_comment", with: "Very good reviewer"
      select "👍 Positive", from: "feedback_rating"
      fill_in "feedback_link", with: "http://nice.review"
      click_on "Save feedback"

      expect(page).to have_content("Feedback saved!")

      visit reviewer_path(@user)

      within("#feedbacks") do
        expect(page).to have_content("Very good reviewer")
        expect(page).to have_link(@editor.github)
        expect(page).to have_link("Reference", href: "http://nice.review")
        expect(page).to have_content("👍")
      end
    end

    scenario "can delete their own feedback" do
      expect(page).to_not have_content("There's no feedback for this reviewer yet.")

      within("#feedback-#{@feedback.id}") do
        expect(page).to have_content("A comment")
        expect(page).to have_content("Delete")
        click_link "Delete"
      end

      expect(page).to have_content("Feedback deleted")

      visit reviewer_path(@user)

      expect(page).to have_content("There's no feedback for this reviewer yet.")
    end

    scenario "can not delete other editor's feedback" do
      other_feedback = create(:feedback, user: @user, editor: create(:editor), comment: "Feedback from other editor")
      visit reviewer_path(@user)

      within("#feedback-#{other_feedback.id}") do
        expect(page).to have_content("Feedback from other editor")
        expect(page).to have_link(other_feedback.editor.github)
        expect(page).to_not have_content("Delete")
      end
    end
  end

end
