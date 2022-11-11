class CreateFeedbacks < ActiveRecord::Migration[7.0]
  def change
    drop_table :ratings do |t|
      t.integer :value
      t.text :comment
      t.string :link
      t.bigint :user_id
      t.bigint :editor_id

      t.timestamps
    end

    create_table :feedbacks do |t|
      t.integer :rating, default: 0
      t.text :comment
      t.string :link
      t.bigint :user_id
      t.bigint :editor_id

      t.timestamps
    end

    add_index :feedbacks, :user_id
    add_index :feedbacks, :editor_id
    add_index :feedbacks, :rating
  end
end
