FactoryBot.define do
  factory :language do
    sequence(:name) {|n| "Programming-lang-#{n}" }
  end
end
