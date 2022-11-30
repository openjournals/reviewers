class CreateStats < ActiveRecord::Migration[7.0]
  def change
    create_table :stats do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :active_reviews, default: 0
      t.integer :reviews_all_time, default: 0
      t.integer :reviews_last_year, default: 0
      t.integer :reviews_last_quarter, default: 0
      t.string :reviews_url_template, default: ""
      t.string :active_reviews_url_template, default: ""

      t.timestamps
    end
  end
end
