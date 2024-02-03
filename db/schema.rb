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

ActiveRecord::Schema[7.1].define(version: 2024_02_03_211745) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "speaker_id", null: false
    t.index ["event_id"], name: "index_event_speakers_on_event_id"
    t.index ["speaker_id"], name: "index_event_speakers_on_speaker_id"
  end

  create_table "events", id: :string, force: :cascade do |t|
    t.string "conference_id", null: false
    t.bigint "track_id", null: false
    t.string "title"
    t.string "abstract"
    t.string "description"
    t.string "type_id"
    t.string "subtitle"
    t.virtual "content", type: :string, as: "(((((((COALESCE(title, ''::character varying))::text || ' '::text) || (COALESCE(subtitle, ''::character varying))::text) || ' '::text) || (COALESCE(abstract, ''::character varying))::text) || ' '::text) || (COALESCE(description, ''::character varying))::text)", stored: true
    t.bigint "favourites_count", default: 0, null: false
    t.string "speaker_names"
    t.virtual "content_searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (((((((((COALESCE(title, ''::character varying))::text || ' '::text) || (COALESCE(subtitle, ''::character varying))::text) || ' '::text) || (COALESCE(abstract, ''::character varying))::text) || ' '::text) || (COALESCE(description, ''::character varying))::text) || ' '::text) || (COALESCE(speaker_names, ''::character varying))::text))", stored: true
    t.date "date"
    t.index ["conference_id"], name: "index_events_on_conference_id"
    t.index ["content_searchable"], name: "events_content_searchable_idx", using: :gin
    t.index ["track_id"], name: "index_events_on_track_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.string "conference_id", null: false
    t.bigint "conference_user_id", null: false
    t.string "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_favourites_on_conference_id"
    t.index ["conference_user_id"], name: "index_favourites_on_conference_user_id"
    t.index ["event_id"], name: "index_favourites_on_event_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
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
