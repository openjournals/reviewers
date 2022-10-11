class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.bigint :user_id
      t.string :state
      t.string :link

      t.timestamps
    end

    add_index :reviews, :user_id
  end
end
