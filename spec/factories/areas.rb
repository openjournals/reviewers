FactoryBot.define do
  factory :area do
    sequence(:name) {|n| "Area-#{n}" }
  end
end
