class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.integer :value
      t.text :comment
      t.string :link
      t.bigint :user_id
      t.bigint :editor_id

      t.timestamps
    end

    add_index :ratings, :user_id
    add_index :ratings, :editor_id
  end
end
