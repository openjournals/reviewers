class Review < ApplicationRecord
  belongs_to :user, counter_cache: true

  validates_presence_of :user_id
  validates_uniqueness_of :external_id, scope: :user_id

  default_scope { order(date: :desc) }
end
