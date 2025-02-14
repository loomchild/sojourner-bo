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

ActiveRecord::Schema[8.0].define(version: 2024_02_15_165405) do
  create_table "conference_users", force: :cascade do |t|
    t.string "conference_id", null: false
    t.string "user_id", null: false
    t.bigint "favourites_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_conference_users_on_conference_id"
    t.index ["user_id"], name: "index_conference_users_on_user_id"
  end

  create_table "conferences", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
  end

  create_table "event_speakers", force: :cascade do |t|
    t.string "event_id", null: false
    t.integer "speaker_id", null: false
    t.index ["event_id"], name: "index_event_speakers_on_event_id"
    t.index ["speaker_id"], name: "index_event_speakers_on_speaker_id"
  end

  create_table "events", id: :string, force: :cascade do |t|
    t.string "conference_id", null: false
    t.integer "track_id", null: false
    t.string "title"
    t.string "abstract"
    t.string "description"
    t.string "type_id"
    t.string "subtitle"
    t.string "speaker_names"
    t.virtual "content", type: :string, as: "lower(coalesce(title,'') || ' ' || coalesce(subtitle, '') || ' ' || coalesce(abstract, '') || ' ' || coalesce(description, '') || ' ' || coalesce(speaker_names, ''))", stored: true
    t.bigint "favourites_count", default: 0, null: false
    t.date "date"
    t.json "meta", default: {}, null: false
    t.index ["conference_id"], name: "index_events_on_conference_id"
    t.index ["track_id"], name: "index_events_on_track_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.string "conference_id", null: false
    t.integer "conference_user_id", null: false
    t.string "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_favourites_on_conference_id"
    t.index ["conference_user_id"], name: "index_favourites_on_conference_user_id"
    t.index ["event_id"], name: "index_favourites_on_event_id"
  end

  create_table "speakers", force: :cascade do |t|
    t.string "conference_id", null: false
    t.string "name"
    t.index ["conference_id", "name"], name: "index_speakers_on_conference_id_and_name", unique: true
    t.index ["conference_id"], name: "index_speakers_on_conference_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "conference_id", null: false
    t.string "name"
    t.index ["conference_id", "name"], name: "index_tracks_on_conference_id_and_name", unique: true
    t.index ["conference_id"], name: "index_tracks_on_conference_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_registered", default: false, null: false
  end

  add_foreign_key "conference_users", "conferences"
  add_foreign_key "conference_users", "users"
  add_foreign_key "event_speakers", "events"
  add_foreign_key "event_speakers", "speakers"
  add_foreign_key "events", "conferences"
  add_foreign_key "events", "tracks"
  add_foreign_key "favourites", "conference_users"
  add_foreign_key "favourites", "conferences"
  add_foreign_key "favourites", "events"
  add_foreign_key "speakers", "conferences"
  add_foreign_key "tracks", "conferences"
end
