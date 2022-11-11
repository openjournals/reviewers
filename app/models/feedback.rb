class Feedback < ApplicationRecord
  enum :rating, { negative: -1, neutral: 0, positive: 1 }, suffix: true

  belongs_to :user, counter_cache: true
  belongs_to :editor, class_name: "User", inverse_of: :given_feedbacks

  validates_presence_of :user_id
  validate :no_empty_neutral_feedback

  default_scope { order(created_at: :desc) }

  def rating_icon
    if positive_rating?
      "👍"
    elsif negative_rating?
      "👎"
    else
      "💬"
    end
  end

  def no_empty_neutral_feedback
    if comment.to_s.strip.empty? && neutral_rating?
      errors.add(:comment, "Comment can't be empty for neutral feedback")
    end
  end
end
