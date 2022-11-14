class AddFeedbackScoreToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :feedback_score, :integer, default: 0
    add_column :users, :feedback_score_last_3, :integer, default: 0
    add_column :users, :feedback_score_last_year, :integer, default: 0
  end
end
