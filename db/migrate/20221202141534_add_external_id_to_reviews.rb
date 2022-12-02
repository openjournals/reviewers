class AddExternalIdToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :external_id, :string
  end
end
