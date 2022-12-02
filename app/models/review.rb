class Review < ApplicationRecord
  belongs_to :user, counter_cache: true

  validates_presence_of :user_id

  default_scope { order(date: :desc) }
end
