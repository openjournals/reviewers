# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_08_23_094546) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "complete_name"
    t.string "citation_name"
    t.string "github", null: false
    t.string "github_token"
    t.string "github_uid", null: false
    t.string "orcid"
    t.string "email"
    t.string "url"
    t.string "github_avatar_url"
    t.string "affiliation"
    t.string "twitter"
    t.text "description", default: ""
    t.boolean "reviewer", default: false
    t.boolean "editor", default: false
    t.boolean "admin", default: false
    t.string "preferred_languages", default: [], array: true
    t.string "other_languages", default: [], array: true
    t.string "subjects", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["complete_name"], name: "index_users_on_complete_name"
    t.index ["github"], name: "index_users_on_github"
    t.index ["orcid"], name: "index_users_on_orcid"
  end

end
