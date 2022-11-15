require 'rails_helper'

RSpec.describe Language, type: :model do

  it "has and belongs to many users" do
    association = Language.reflect_on_association(:users)
    expect(association.macro).to eq(:has_and_belongs_to_many)
  end

  it "name is unique" do
    language_1 = create(:language, name: "Astrophysics")
    expect(language_1).to be_valid

    language_2 = build(:language, name: "Astrophysics")
    expect(language_2).to_not be_valid
  end

  it "by default is ordered alphabetically" do
    create(:language, name: "Python")
    create(:language, name: "Ruby")
    create(:language, name: "Go")

    languages = Language.all
    expect(languages[0].name).to eq("Go")
    expect(languages[1].name).to eq("Python")
    expect(languages[2].name).to eq("Ruby")
  end

end
