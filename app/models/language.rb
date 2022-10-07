class Language < ApplicationRecord
  has_and_belongs_to_many :users

  validates :name, uniqueness: true, presence: true
end
