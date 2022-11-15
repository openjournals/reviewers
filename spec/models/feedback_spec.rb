require 'rails_helper'

RSpec.describe Feedback, type: :model do

  describe "associations" do
    it "belongs to user" do
      association = Feedback.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to editor" do
      association = Feedback.reflect_on_association(:editor)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  it "user is mandatory" do
    feedback = build(:feedback, user: nil, comment: "OK")
    expect(feedback).to_not be_valid
    expect(feedback.errors[:user]).to_not be_empty
  end

  it "has rating icons" do
    expect(create(:feedback, :positive).rating_icon).to eq("👍")
    expect(create(:feedback, :negative).rating_icon).to eq("👎")
    expect(create(:feedback, :neutral).rating_icon).to eq("💬")
  end

  it "neutral feedbacks without comment are not allowed" do
    feedback = build(:feedback, :neutral, comment: "  ")
    expect(feedback).to_not be_valid
    expect(feedback.errors[:comment]).to eq(["Comment can't be empty for neutral feedback"])

    expect(build(:feedback, :neutral, comment: nil)).to_not be_valid
    expect(build(:feedback, :neutral, comment: "Hey!")).to be_valid
  end

  it "should recalculate feedback scores on user afteer creation" do
    user = create(:user)
    expect(user).to receive(:calculate_feedback_scores)
    create(:feedback, user: user)
  end


  it "should recalculate feedback scores on user afteer creation" do
    user = create(:user)
    feedback = create(:feedback, user: user)

    expect(user).to receive(:calculate_feedback_scores)
    feedback.destroy
  end
end
