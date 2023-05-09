require 'rails_helper'

RSpec.describe "Search reviewers", type: :system do
  before do
    driven_by :rack_test
  end

  scenario "Is available to logged in users" do
    visit search_reviewers_path
    expect(page).to have_current_path(root_path)
    visit reviewers_path
    expect(page).to have_current_path(root_path)

    login_as create(:reviewer)
    visit root_path
    expect(page).to have_content("Search reviewers")
    click_link("Search reviewers")
    expect(page).to have_current_path(reviewers_path)
    visit search_reviewers_path
    expect(page).to have_current_path(search_reviewers_path)

    login_as create(:editor)
    visit root_path
    expect(page).to have_content("Search reviewers")
    click_link("Search reviewers")
    expect(page).to have_current_path(reviewers_path)
    visit search_reviewers_path
    expect(page).to have_current_path(search_reviewers_path)

    login_as create(:admin)
    visit root_path
    expect(page).to have_content("Search reviewers")
    click_link("Search reviewers")
    expect(page).to have_current_path(reviewers_path)
    visit search_reviewers_path
    expect(page).to have_current_path(search_reviewers_path)
  end

  scenario "Only lists reviewers" do
    @reviewer_1 = create(:reviewer)
    @reviewer_2 = create(:reviewer)
    @user = create(:user)
    @editor = create(:editor)
    @admin = create(:admin)

    login_as create(:editor)
    visit reviewers_path

    expect(page).to have_content(@reviewer_1.complete_name)
    expect(page).to have_content(@reviewer_2.complete_name)
    expect(page).to_not have_content(@user.complete_name)
    expect(page).to_not have_content(@editor.complete_name)
    expect(page).to_not have_content(@admin.complete_name)
  end

  describe "Search" do
    before do
      @reviewer_1 = create(:reviewer, complete_name: "TesterUser33", github: "tester-user-33", domains: "big trees, oceans")
      @reviewer_1.languages << create(:language, name: "Python")
      @reviewer_1.areas << create(:area, name: "Plant Science")

      @reviewer_2 = create(:reviewer, complete_name: "TesterUser21", github: "tester21", domains: "astroplanetary science")
      @reviewer_2.languages << create(:language, name: "Julia")
      @reviewer_2.areas << create(:area, name: "Astrophysics")

      @reviewer_3 = create(:reviewer, complete_name: "TesterUser42", github: "biouser", twitter: "biotester", domains: "cell biology, oceanography")
      @reviewer_3.languages << create(:language, name: "Ruby")
      @reviewer_3.areas << create(:area, name: "Biomedicine")

      @editor = create(:editor)

      login_as @editor
      visit reviewers_path
      expect(page).to have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to have_content(@reviewer_3.complete_name)
    end

    scenario "search by language" do
      select "Python", from: "language"
      click_on "Search"

      expect(page).to have_content(@reviewer_1.complete_name)
      expect(page).to_not have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)
    end

    scenario "search by area if more than 10 (autocomplete)" do
      create_list(:area, 10)
      visit search_reviewers_path

      find("#area_id", visible: false).set(Area.find_by(name: "Astrophysics").id)
      click_on "Update search"

      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)
    end

    scenario "search by area if less than 10 (select)" do
      select "Astrophysics", from: "area_id"
      click_on "Search"

      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)
    end

    scenario "search by username" do
      fill_in "name", with: "biouser"
      click_on "Search"

      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to_not have_content(@reviewer_2.complete_name)
      expect(page).to have_content(@reviewer_3.complete_name)

      fill_in "name", with: "tester"
      click_on "Update search"

      expect(page).to have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to have_content(@reviewer_3.complete_name)
    end

    scenario "search by keywords" do
      fill_in "keywords", with: "cell"
      click_on "Search"

      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to_not have_content(@reviewer_2.complete_name)
      expect(page).to have_content(@reviewer_3.complete_name)

      fill_in "keywords", with: "tr"
      click_on "Update search"

      expect(page).to have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)
    end

    scenario "search by multiple parameters" do
      select "Julia", from: "language"
      select "Astrophysics", from: "area_id"
      fill_in "keywords", with: "planetary"
      fill_in "name", with: "tester"
      click_on "Search"

      expect(page).to have_content("Language: Julia Area: Astrophysics Keywords: planetary By user: tester")
      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)

      expect(page).to have_content("Load")
      expect(page).to have_content("Scores")
    end

    scenario "search by multiple parameters as a User" do
      login_as create(:reviewer)
      visit reviewers_path
      expect(page).to have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)

      select "Julia", from: "language"
      select "Astrophysics", from: "area_id"
      fill_in "keywords", with: "planetary"
      fill_in "name", with: "tester"
      click_on "Search"

      within("#search-info") do
        expect(page).to have_content("Language: Julia Area: Astrophysics Keywords: planetary By user: tester")
      end
      expect(page).to_not have_content(@reviewer_1.complete_name)
      expect(page).to have_content(@reviewer_2.complete_name)
      expect(page).to_not have_content(@reviewer_3.complete_name)

      expect(page).to_not have_content("Scores")
      expect(page).to_not have_content("Load")
    end

    describe "Reorder" do
      before do
        @reviewer_1.stat.update(active_reviews: 5)
        @reviewer_2.stat.update(active_reviews: 10)
        @reviewer_3.stat.update(active_reviews: 1)

        @reviewer_1.update(feedback_score_last_3: -3)
        @reviewer_2.update(feedback_score_last_3: 0)
        @reviewer_3.update(feedback_score_last_3: 2)

        @reviewer1_data = "TesterUser33 @tester-user-33 Python big trees, oceans 5"
        @reviewer2_data = "TesterUser21 @tester21 Julia astroplanetary science 10"
        @reviewer3_data = "TesterUser42 @biouser Ruby cell biology, oceanography 1"

        visit search_reviewers_path
      end

      scenario "by active reviews" do
        click_on "Load"
        expect(page).to have_content([@reviewer2_data, @reviewer1_data, @reviewer3_data]*" ")

        click_on "Load"
        expect(page).to have_content([@reviewer3_data, @reviewer1_data, @reviewer2_data]*" ")

        click_on "Load"
        expect(page).to have_content([@reviewer2_data, @reviewer1_data, @reviewer3_data]*" ")
      end

      scenario "by score" do
        click_on "Score"
        expect(page).to have_content([@reviewer3_data, @reviewer2_data, @reviewer1_data]*" ")

        click_on "Score"
        expect(page).to have_content([@reviewer1_data, @reviewer2_data, @reviewer3_data]*" ")

        click_on "Score"
        expect(page).to have_content([@reviewer3_data, @reviewer2_data, @reviewer1_data]*" ")
      end

      scenario "works in the index page too" do
        visit reviewers_path

        click_on "Load"
        expect(page).to have_content([@reviewer2_data, @reviewer1_data, @reviewer3_data]*" ")

        click_on "Load"
        expect(page).to have_content([@reviewer3_data, @reviewer1_data, @reviewer2_data]*" ")

        click_on "Load"
        expect(page).to have_content([@reviewer2_data, @reviewer1_data, @reviewer3_data]*" ")
      end

      scenario "should keep search params" do
        within("#search-info") do
          expect(page).to_not have_content("Keywords:")
          expect(page).to_not have_content("By user:")
        end

        click_on "Load"
        within("#search-info") do
          expect(page).to_not have_content("Keywords:")
          expect(page).to_not have_content("By user:")
        end
        expect(page).to have_content(@reviewer_1.complete_name)
        expect(page).to have_content(@reviewer_2.complete_name)
        expect(page).to have_content(@reviewer_3.complete_name)

        fill_in "keywords", with: "ocean"
        fill_in "name", with: "tester"
        click_on "Update search"

        within("#search-info") { expect(page).to have_content("Keywords: ocean By user: tester") }
        expect(page).to have_content(@reviewer_1.complete_name)
        expect(page).to_not have_content(@reviewer_2.complete_name)
        expect(page).to have_content(@reviewer_3.complete_name)

        click_on "Load"
        within("#search-info") { expect(page).to have_content("Keywords: ocean By user: tester") }
        expect(page).to have_content([@reviewer1_data, @reviewer3_data]*" ")
        expect(page).to_not have_content(@reviewer_2.complete_name)

        click_on "Load"
        within("#search-info") { expect(page).to have_content("Keywords: ocean By user: tester") }
        expect(page).to have_content([@reviewer3_data, @reviewer1_data]*" ")
        expect(page).to_not have_content(@reviewer_2.complete_name)
      end
    end
  end

end
