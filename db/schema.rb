# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181017200116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_sets", force: :cascade do |t|
    t.string   "name"
    t.integer  "tcg_id"
    t.integer  "ck_id"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.string   "name"
    t.integer  "tcg_id"
    t.boolean  "is_foil"
    t.integer  "card_set_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "hidden"
    t.index ["card_set_id"], name: "index_cards_on_card_set_id", using: :btree
  end

  create_table "prices", force: :cascade do |t|
    t.float    "tcg_price"
    t.float    "ck_price"
    t.integer  "card_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.float    "spread"
    t.datetime "ck_updated"
    t.float    "lowest_listing_price"
    t.index ["card_id"], name: "index_prices_on_card_id", using: :btree
  end

  add_foreign_key "cards", "card_sets"
  add_foreign_key "prices", "cards"
end
