class AddLastActionKeyToStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :last_action_key, :string
  end
end
