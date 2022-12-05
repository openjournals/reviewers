require 'rails_helper'

RSpec.describe Stat, type: :model do

  it "belongs to user" do
    association = Stat.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end
end
