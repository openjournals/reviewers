FactoryBot.define do
  factory :review do
    user { create(:reviewer) }
    date { 1.month.ago }
    sequence(:external_id) {|n| "#{n}"}
  end
end
