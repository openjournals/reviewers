class ChangeGithubUidRequirement < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :github_uid, true
  end
end
