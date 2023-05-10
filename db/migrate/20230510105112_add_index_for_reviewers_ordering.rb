class AddIndexForReviewersOrdering < ActiveRecord::Migration[7.0]
  def change
    add_index :users, [:feedback_score_last_3, :feedback_score, :feedbacks_count],  name: 'by_feedback_scores'
    add_index :stats, :active_reviews
  end
end
