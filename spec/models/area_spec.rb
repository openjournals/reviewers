require 'rails_helper'

RSpec.describe Area, type: :model do

  it "has and belongs to many users" do
    association = Area.reflect_on_association(:users)
    expect(association.macro).to eq(:has_and_belongs_to_many)
  end

  it "name is unique" do
    area_1 = create(:area, name: "Astrophysics")
    expect(area_1).to be_valid

    area_2 = build(:area, name: "Astrophysics")
    expect(area_2).to_not be_valid
  end

  it "by default is ordered alphabetically" do
    Area.delete_all

    create(:area, name: "Biomedicine")
    create(:area, name: "Chemistry")
    create(:area, name: "Astronomy")

    areas = Area.all
    expect(areas[0].name).to eq("Astronomy")
    expect(areas[1].name).to eq("Biomedicine")
    expect(areas[2].name).to eq("Chemistry")
  end

end
