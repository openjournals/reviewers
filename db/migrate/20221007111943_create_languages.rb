class CreateLanguages < ActiveRecord::Migration[7.0]
  def change
    create_table :languages do |t|
      t.string :name

      t.timestamps
    end

    add_index :languages, :name

    create_join_table :users, :languages
  end
end
