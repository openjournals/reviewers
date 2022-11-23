require 'rails_helper'

RSpec.describe "Admin dashboard", type: :system do
  before do
    driven_by :rack_test
  end

  scenario "Is only available to admins" do
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

    login_as create(:editor)
    visit root_path
    expect(page).to_not have_content("Manage users")
    expect {
      visit admin_path
    }.to raise_exception(ActionController::RoutingError, "Not Found")

    login_as create(:admin)
    visit root_path
    expect(page).to have_content("Manage users")
    click_link("Manage users")
    expect(page).to have_current_path(admin_path)
  end

end