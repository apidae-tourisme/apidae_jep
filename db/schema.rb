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

ActiveRecord::Schema.define(version: 2019_04_09_124224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "attached_files", id: :serial, force: :cascade do |t|
    t.integer "program_item_id"
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "auth_tokens", id: :serial, force: :cascade do |t|
    t.datetime "expiration_date"
    t.text "token"
    t.string "member_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "communication_polls", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.string "town_insee_code"
    t.string "phone"
    t.string "email"
    t.string "delivery_address"
    t.string "delivery_insee_code"
    t.text "communication_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.text "delivery_comments"
  end

  create_table "event_polls", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "status"
    t.text "event_data"
    t.text "offers_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_openings", id: :serial, force: :cascade do |t|
    t.integer "program_item_id"
    t.string "type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "duration"
    t.integer "frequency"
  end

  create_table "jep_sites", id: :serial, force: :cascade do |t|
    t.text "description"
    t.text "site_data"
    t.uuid "place_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_uid"], name: "index_jep_sites_on_place_uid", unique: true
  end

  create_table "legal_entities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "address"
    t.string "website"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_id"
    t.string "town_insee_code"
    t.index ["name"], name: "index_legal_entities_on_name"
  end

  create_table "moderators", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "telephone"
    t.string "role"
    t.text "apidae_data"
    t.string "notification_email"
    t.string "member_ref"
    t.boolean "active"
    t.index ["email"], name: "index_moderators_on_email", unique: true
    t.index ["reset_password_token"], name: "index_moderators_on_reset_password_token", unique: true
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "town_insee_code"
    t.text "address_data"
    t.float "latitude"
    t.float "longitude"
    t.float "altitude"
    t.string "source"
    t.text "access_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "desc_data"
    t.uuid "uid"
    t.string "country"
    t.index ["uid"], name: "index_places_on_uid", unique: true
  end

  create_table "program_items", id: :serial, force: :cascade do |t|
    t.integer "program_id"
    t.integer "external_id"
    t.integer "rev"
    t.string "title"
    t.text "description"
    t.text "details"
    t.string "status"
    t.text "desc_data"
    t.text "location_data"
    t.text "rates_data"
    t.text "opening_data"
    t.text "contact_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_type"
    t.integer "reference"
    t.integer "ordering"
    t.text "history_data"
    t.integer "user_id"
    t.string "external_status"
    t.text "summary"
    t.index ["reference"], name: "index_program_items_on_reference"
  end

  create_table "programs", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "programs_users", id: :serial, force: :cascade do |t|
    t.integer "program_id"
    t.integer "user_id"
  end

  create_table "towns", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "postal_code"
    t.string "insee_code"
    t.string "country"
    t.string "territory"
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insee_code"], name: "index_towns_on_insee_code"
    t.index ["name"], name: "index_towns_on_name"
    t.index ["postal_code"], name: "index_towns_on_postal_code"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "telephone"
    t.string "role"
    t.text "apidae_data"
    t.integer "legal_entity_id"
    t.boolean "communication"
    t.string "territory"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["territory"], name: "index_users_on_territory"
  end

end
