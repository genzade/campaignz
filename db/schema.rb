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

ActiveRecord::Schema[7.0].define(version: 2023_05_14_085610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaign_episodes", force: :cascade do |t|
    t.integer "score", default: 0
    t.integer "invalid_votes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "candidate_id", null: false
    t.bigint "campaign_id", null: false
    t.index ["campaign_id"], name: "index_campaign_episodes_on_campaign_id"
    t.index ["candidate_id"], name: "index_campaign_episodes_on_candidate_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.integer "total_votes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "candidates", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "campaign_episodes", "campaigns"
  add_foreign_key "campaign_episodes", "candidates"
end
