class RemoveColumnsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :preferred_languages, default: [], array: true
    remove_column :users, :other_languages, default: [], array: true
    remove_column :users, :subjects, default: [], array: true
  end
end
