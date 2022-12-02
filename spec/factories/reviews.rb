FactoryBot.define do
  factory :review do
    user { create(:reviewer) }
    date { 1.month.ago }
  end
end
