require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { create(:user) }

  describe "associations" do
    it "has and belongs to many areas" do
      association = User.reflect_on_association(:areas)
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end

    it "has and belongs to many languages" do
      association = User.reflect_on_association(:languages)
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end

    it "has many feedbacks" do
      association = User.reflect_on_association(:feedbacks)
      expect(association.macro).to eq(:has_many)
    end

    it "has many given_feedbacks" do
      association = User.reflect_on_association(:given_feedbacks)
      expect(association.macro).to eq(:has_many)
    end

    it "has stats" do
      association = User.reflect_on_association(:stat)
      expect(association.macro).to eq(:has_one)
    end
  end

  describe "scopes" do
    before do
      create_list(:user, 7)
      create_list(:reviewer, 5)
      create_list(:editor, 4)
      create(:admin)
    end

    it "for reviewers" do
      reviewers = User.reviewers
      expect(reviewers.size).to eq(5)
      reviewers.each {|r| expect(r.reviewer?).to be true}
    end

    it "for editors" do
      editors = User.editors
      expect(editors.size).to eq(4)
      editors.each {|r| expect(r.editor?).to be true}
    end

    it "for admins" do
      admins = User.admins
      expect(admins.size).to eq(1)
      admins.each {|r| expect(r.admin?).to be true}
    end
  end

  it "github handle is unique" do
    user_1 = create(:user, github: "user-1")
    expect(user_1).to be_valid

    user_2 = build(:user, github: "user-1")
    expect(user_2).to_not be_valid
  end

  it "#avatar has default value" do
    user_with_avatar = create(:user, github_avatar_url: "https://test-url.to/avatar.jpg")
    user_without_avatar = create(:user)

    expect(user_with_avatar.avatar).to eq("https://test-url.to/avatar.jpg")
    expect(user_without_avatar.avatar).to eq("default_avatar.png")
  end

  describe "#screen_name" do
    it "returns complete name if present" do
      user = create(:user, complete_name: "Sarah Tester")
      expect(user.screen_name).to eq("Sarah Tester")
    end

    it "returns github handle if no complete name" do
      user = create(:user, complete_name: nil, github: "tester")
      expect(user.screen_name).to eq("@tester")
    end
  end

  describe "#calculate_feedback_scores" do
    before do
      @user = create(:reviewer)
    end

    it "resets the all-time feedback score" do
      expect(@user.feedback_score).to eq(0)
      create_list(:feedback, 3, :positive, user: @user)
      create_list(:feedback, 2, :negative, user: @user)
      create_list(:feedback, 1, :neutral, user: @user, comment: "meh")
      expect(@user.reload.feedback_score).to eq(1)

      create_list(:feedback, 3, :positive, user: @user)
      @user.update_attribute(:feedback_score, 7)
      expect(@user.reload.feedback_score).to eq(7)

      @user.calculate_feedback_scores
      expect(@user.reload.feedback_score).to eq(4)
    end

    it "resets the score for the last 3 feedbacks" do
      expect(@user.feedback_score_last_3).to eq(0)
      create_list(:feedback, 3, :positive, user: @user)
      create_list(:feedback, 2, :negative, user: @user)
      create_list(:feedback, 1, :neutral, user: @user, comment: "meh")
      expect(@user.reload.feedback_score_last_3).to eq(-2)

      create_list(:feedback, 3, :positive, user: @user)
      @user.update_attribute(:feedback_score_last_3, 7)
      expect(@user.reload.feedback_score_last_3).to eq(7)

      @user.calculate_feedback_scores
      expect(@user.reload.feedback_score_last_3).to eq(3)
    end

    it "resets the score of the last 12 months" do
      expect(@user.feedback_score_last_year).to eq(0)
      create_list(:feedback, 3, :positive, user: @user)
      create_list(:feedback, 2, :negative, user: @user, created_at: 13.months.ago)
      create_list(:feedback, 1, :neutral, user: @user, comment: "meh")
      expect(@user.reload.feedback_score_last_year).to eq(3)

      create(:feedback, :positive, user: @user, created_at: 11.months.ago)
      create(:feedback, :positive, user: @user, created_at: 14.months.ago)
      @user.update_attribute(:feedback_score_last_year, 7)
      expect(@user.reload.feedback_score_last_year).to eq(7)

      @user.calculate_feedback_scores
      expect(@user.reload.feedback_score_last_year).to eq(4)
    end
  end

  describe "#profile_complete?" do
    it "is true if complete_name, email, affiliation and areas are present" do
      reviewer = create(:reviewer, complete_name: "Rev I. Ewer", email: "rev@iew.er", affiliation: "Tyrell corp", areas: [create(:area)] )
      expect(reviewer).to be_profile_complete

      reviewer = create(:reviewer, complete_name: "", email: "rev@iew.er", affiliation: "Tyrell corp", areas: [create(:area)] )
      expect(reviewer).to_not be_profile_complete

      reviewer = create(:reviewer, complete_name: "Rev I. Ewer", email: "", affiliation: "Tyrell corp", areas: [create(:area)] )
      expect(reviewer).to_not be_profile_complete

      reviewer = create(:reviewer, complete_name: "Rev I. Ewer", email: "rev@iew.er", affiliation: "", areas: [create(:area)] )
      expect(reviewer).to_not be_profile_complete

      reviewer = create(:reviewer, complete_name: "Rev I. Ewer", email: "rev@iew.er", affiliation: "Tyrell corp", areas: [] )
      expect(reviewer).to_not be_profile_complete
    end
  end

  describe "#from_github_omniauth" do
    let(:auth_info) { double(uid: "123456",
                             info: double(nickname: "test-auth-user",
                                          email: "auth@test.ing",
                                          image: "/authtest_avatar.png"),
                             credentials: double(token: "abcdefg"))
                    }

    it "finds the already authorized user updating the github data" do
      user = create(:user, github_uid: "123456", email: nil, github_avatar_url: "old-image.jpg", github_token: "ABC")

      expect {
        returned_user = User.from_github_omniauth(auth_info, {})

        expect(returned_user.id).to eq(user.id)
        expect(returned_user.email).to eq("auth@test.ing")
        expect(returned_user.github_token).to eq("abcdefg")
        expect(returned_user.github_avatar_url).to eq("/authtest_avatar.png")
      }.to_not change { User.count }
    end

    it "keeps email for already authorized users if present" do
      user = create(:user, github_uid: "123456", email: "myemail@reviewerste.st", github_avatar_url: "old-image.jpg", github_token: "ABC")

      expect {
        returned_user = User.from_github_omniauth(auth_info, {})

        expect(returned_user.id).to eq(user.id)
        expect(returned_user.email).to eq("myemail@reviewerste.st")
        expect(returned_user.github_token).to eq("abcdefg")
        expect(returned_user.github_avatar_url).to eq("/authtest_avatar.png")
      }.to_not change { User.count }
    end

    it "finds a recurring user with updated github handle" do
      user = create(:user, github: "oldhandle", github_uid: "123456")

      expect {
        returned_user = User.from_github_omniauth(auth_info, {})

        expect(returned_user.id).to eq(user.id)
        expect(returned_user.github).to eq("test-auth-user")
      }.to_not change { User.count }
    end

    it "creates a new reviewer if it doesn't exist" do
      expect {
        new_user = User.from_github_omniauth(auth_info)

        expect(new_user.github_uid).to eq("123456")
        expect(new_user.github).to eq("test-auth-user")
        expect(new_user.email).to eq("auth@test.ing")
        expect(new_user.github_avatar_url).to eq("/authtest_avatar.png")
        expect(new_user.github_token).to eq("abcdefg")
        expect(new_user.reviewer).to eq(true)
      }.to change { User.count }.by(1)
    end

    it "associates new data to an existing user" do
      user = create(:user, github_uid: nil, github: "test-auth-user" , email: "user@ema.il", affiliation: "Scilab")

      expect {
        logged_user = User.from_github_omniauth(auth_info)

        expect(logged_user).to eq(user.reload)
        expect(logged_user.github_uid).to eq("123456")
        expect(logged_user.github).to eq("test-auth-user")
        expect(logged_user.email).to eq("auth@test.ing")
        expect(logged_user.github_avatar_url).to eq("/authtest_avatar.png")
        expect(logged_user.github_token).to eq("abcdefg")
        expect(logged_user.reviewer).to eq(true)
        expect(logged_user.id).to eq(user.id)
        expect(logged_user.affiliation).to eq("Scilab")
      }.to_not change { User.count }
    end

    it "allows skipping marking new user as available to review" do
      expect {
        new_user = User.from_github_omniauth(auth_info, {"reviewer" => "no"})

        expect(new_user.github_uid).to eq("123456")
        expect(new_user.github).to eq("test-auth-user")
        expect(new_user.email).to eq("auth@test.ing")
        expect(new_user.github_avatar_url).to eq("/authtest_avatar.png")
        expect(new_user.github_token).to eq("abcdefg")
        expect(new_user.reviewer).to eq(false)
      }.to change { User.count }.by(1)
    end
  end
end
