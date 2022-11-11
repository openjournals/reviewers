class Feedback < ApplicationRecord
  enum :rating, negative: -1, neutral: 0, positive: 1, suffix: true

  belongs_to :user, counter_cache: true
  belongs_to :editor, class_name: "User", inverse_of: :given_feedbacks
end
