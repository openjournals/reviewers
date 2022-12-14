class RemoveReviews < ActiveRecord::Migration[7.0]
  def change
    drop_table :reviews do |t|
      t.bigint :user_id
      t.string :state
      t.string :link
      t.date :date
      t.string :external_id
      t.timestamps
    end

    remove_column :users, :reviews_count, :integer, default: 0
  end
end
