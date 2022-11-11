class AddFeedbacksCounterCacheToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :feedbacks_count, :integer, default: 0
  end
end
