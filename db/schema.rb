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

ActiveRecord::Schema.define(version: 20170408181652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "attached_files", force: :cascade do |t|
    t.integer  "program_item_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.text     "data"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "item_openings", force: :cascade do |t|
    t.integer  "program_item_id"
    t.string   "type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "description"
    t.integer  "duration"
    t.integer  "frequency"
  end

  create_table "legal_entities", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.text     "address"
    t.string   "postal_code"
    t.string   "town"
    t.string   "website"
    t.string   "phone"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "external_id"
  end

  add_index "legal_entities", ["name"], name: "index_legal_entities_on_name", using: :btree
  add_index "legal_entities", ["postal_code"], name: "index_legal_entities_on_postal_code", using: :btree
  add_index "legal_entities", ["town"], name: "index_legal_entities_on_town", using: :btree

  create_table "moderators", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "telephone"
    t.string   "role"
    t.text     "apidae_data"
    t.string   "notification_email"
    t.string   "member_ref"
  end

  add_index "moderators", ["email"], name: "index_moderators_on_email", unique: true, using: :btree
  add_index "moderators", ["reset_password_token"], name: "index_moderators_on_reset_password_token", unique: true, using: :btree

  create_table "program_items", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "external_id"
    t.integer  "rev"
    t.string   "title"
    t.text     "description"
    t.text     "details"
    t.string   "status"
    t.text     "desc_data"
    t.text     "location_data"
    t.text     "rates_data"
    t.text     "opening_data"
    t.text     "contact_data"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "item_type"
    t.integer  "reference"
    t.integer  "ordering"
  end

  add_index "program_items", ["reference"], name: "index_program_items_on_reference", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "programs_users", force: :cascade do |t|
    t.integer "program_id"
    t.integer "user_id"
  end

  create_table "towns", force: :cascade do |t|
    t.string   "name"
    t.string   "postal_code"
    t.string   "insee_code"
    t.string   "country"
    t.string   "territory"
    t.integer  "external_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "towns", ["name"], name: "index_towns_on_name", using: :btree
  add_index "towns", ["postal_code"], name: "index_towns_on_postal_code", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "telephone"
    t.string   "role"
    t.text     "apidae_data"
    t.integer  "legal_entity_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
