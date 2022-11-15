FactoryBot.define do
  factory :feedback do
    user { create(:reviewer) }
    editor { create(:editor) }
  end
end
