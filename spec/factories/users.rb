FactoryBot.define do
  factory :user do
    sequence(:complete_name) {|n| "User_#{n}" }
    sequence(:citation_name) {|n| "U. #{n}." }
    sequence(:email) {|n| "user#{n}@researchcenter#{n}.org" }
    sequence(:affiliation) {|n| "Research center #{n}" }
    sequence(:github) {|n| "testuser#{n}" }
    reviewer { false }
    editor { false }
    admin { false }

    factory :reviewer do
      reviewer { true }
    end

    factory :editor do
      editor { true }
    end

    factory :admin do
      admin { true }
    end
  end
end
