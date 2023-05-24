class DeleteTwitterFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :twitter, :string
  end
end
