# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150327211450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "remote_cards", force: :cascade do |t|
    t.integer "remote_wallet_id"
    t.string "card_token", null: false
    t.string "card_type"
    t.date "expiration_date"
    t.string "card_number", null: false
  end

  add_index "remote_cards", ["card_token"], name: "index_remote_cards_on_card_token", unique: true, using: :btree
  add_index "remote_cards", ["remote_wallet_id"], name: "index_remote_cards_on_remote_wallet_id", using: :btree

  create_table "remote_wallets", force: :cascade do |t|
    t.string "wallet_token", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "age"
    t.string "account_number"
  end

  add_index "remote_wallets", ["wallet_token"], name: "index_remote_wallets_on_wallet_token", unique: true, using: :btree

  add_foreign_key "remote_cards", "remote_wallets"
end
