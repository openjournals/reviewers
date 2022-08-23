class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :complete_name
      t.string :citation_name
      t.string :github, null: false
      t.string :github_token
      t.string :github_uid, null: false
      t.string :orcid
      t.string :email
      t.string :url
      t.string :github_avatar_url
      t.string :affiliation
      t.string :twitter
      t.text :description, default: ""
      t.boolean :reviewer, default: false
      t.boolean :editor, default: false
      t.boolean :admin, default: false

      t.string :preferred_languages, array: true, default: []
      t.string :other_languages, array: true, default: []
      t.string :subjects, array: true, default: []

      t.timestamps
    end

    add_index :users, :github
    add_index :users, :orcid
    add_index :users, :complete_name
  end
end
