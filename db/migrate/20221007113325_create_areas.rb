class CreateAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :areas do |t|
      t.string :name

      t.timestamps
    end

    add_index :areas, :name

    create_join_table :users, :areas
  end
end
