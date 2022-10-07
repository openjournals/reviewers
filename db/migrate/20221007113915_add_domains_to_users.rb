class AddDomainsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :domains, :string
  end
end
