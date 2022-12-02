require 'rails_helper'

RSpec.describe Review, type: :model do

  it "has and belongs to many users" do
    association = Review.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  it "by default is ordered by date" do
    create(:review, date: 1.year.ago)
    create(:review, date: 1.day.ago)
    create(:review, date: 1.month.ago)

    reviews = Review.all
    expect(reviews[0].date).to eq(1.day.ago.to_date)
    expect(reviews[1].date).to eq(1.month.ago.to_date)
    expect(reviews[2].date).to eq(1.year.ago.to_date)
  end

end
