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

ActiveRecord::Schema[7.1].define(version: 2023_11_12_151027) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "oban_job_state", ["available", "scheduled", "executing", "retryable", "completed", "discarded", "cancelled"]

  create_table "agencies", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.uuid "avatar_key"
    t.string "avatar_extension", limit: 255
    t.datetime "deleted_at", precision: 0
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.boolean "created_on_import", default: false, null: false
    t.string "acronym", limit: 255
    t.bigint "parent_id"
  end

  create_table "agency_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "agency_id", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["user_id"], name: "agency_members_user_id_index", unique: true
  end

  create_table "certification_log", force: :cascade do |t|
    t.bigint "approver_id"
    t.string "approver_role", limit: 255
    t.string "approver_identifier", limit: 255
    t.string "approver_remote_ip", limit: 255
    t.bigint "user_id", null: false
    t.string "user_role", limit: 255
    t.string "user_identifier", limit: 255
    t.string "user_remote_ip", limit: 255
    t.datetime "requested_at", precision: 0
    t.datetime "certified_at", precision: 0
    t.datetime "expires_at", precision: 0
    t.datetime "denied_at", precision: 0
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "challenge_managers", id: :bigint, default: -> { "nextval('challenge_owners_id_seq'::regclass)" }, force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "user_id"
    t.datetime "revoked_at", precision: 0
  end

  create_table "challenges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "description"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "status", limit: 255, default: "pending", null: false
    t.date "captured_on"
    t.date "published_on"
    t.string "title", limit: 255
    t.text "tagline"
    t.string "poc_email", limit: 255
    t.string "agency_name", limit: 255
    t.text "how_to_enter"
    t.text "rules"
    t.string "external_url", limit: 255
    t.string "custom_url", limit: 255
    t.datetime "start_date", precision: 0
    t.datetime "end_date", precision: 0
    t.string "fiscal_year", limit: 255
    t.string "type", limit: 255
    t.bigint "prize_total", null: false
    t.text "prize_description"
    t.text "judging_criteria"
    t.string "challenge_manager", limit: 255
    t.string "legal_authority", limit: 255
    t.text "terms_and_conditions"
    t.text "non_monetary_prizes"
    t.text "federal_partners"
    t.text "faq"
    t.text "winner_information"
    t.text "number_of_phases"
    t.text "phase_descriptions"
    t.text "phase_dates"
    t.text "brief_description"
    t.boolean "multi_phase"
    t.text "eligibility_requirements"
    t.string "challenge_manager_email", limit: 255
    t.bigint "agency_id"
    t.uuid "logo_key"
    t.string "logo_extension", limit: 255
    t.uuid "winner_image_key"
    t.string "winner_image_extension", limit: 255
    t.string "last_section", limit: 255
    t.jsonb "types"
    t.datetime "auto_publish_date", precision: 0
    t.datetime "deleted_at", precision: 0
    t.text "rejection_message"
    t.jsonb "phases"
    t.boolean "upload_logo"
    t.boolean "is_multi_phase"
    t.jsonb "timeline_events"
    t.string "prize_type", limit: 255
    t.boolean "terms_equal_rules"
    t.string "how_to_enter_link", limit: 255
    t.uuid "resource_banner_key"
    t.string "resource_banner_extension", limit: 255
    t.boolean "imported", default: false, null: false
    t.text "description_delta"
    t.text "prize_description_delta"
    t.text "faq_delta"
    t.text "eligibility_requirements_delta"
    t.text "rules_delta"
    t.text "terms_and_conditions_delta"
    t.uuid "uuid"
    t.bigint "sub_agency_id"
    t.string "primary_type", limit: 255
    t.string "other_type", limit: 255
    t.text "announcement"
    t.datetime "announcement_datetime", precision: 0
    t.string "sub_status", limit: 255
    t.string "gov_delivery_topic", limit: 255
    t.datetime "archive_date", precision: 0
    t.integer "gov_delivery_subscribers", default: 0, null: false
    t.text "brief_description_delta"
    t.string "logo_alt_text", limit: 255
    t.string "short_url", limit: 255
    t.string "submission_collection_method", limit: 255
    t.boolean "file_upload_required", default: false
    t.string "upload_instruction_note", limit: 255
    t.index ["custom_url"], name: "challenges_custom_url_index", unique: true
  end

  create_table "dap_reports", force: :cascade do |t|
    t.string "filename", limit: 255, null: false
    t.uuid "key", null: false
    t.string "extension", limit: 255, null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "federal_partners", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.bigint "challenge_id", null: false
    t.bigint "sub_agency_id"
  end

  create_table "message_context_statuses", force: :cascade do |t|
    t.bigint "message_context_id", null: false
    t.bigint "user_id", null: false
    t.boolean "read", default: false
    t.boolean "starred", default: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.boolean "archived", default: false
  end

  create_table "message_contexts", force: :cascade do |t|
    t.string "context", limit: 255, null: false
    t.integer "context_id", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.bigint "last_message_id"
    t.string "audience", limit: 255
    t.bigint "parent_id"
    t.index ["context", "context_id", "audience", "parent_id"], name: "message_contexts_context_context_id_audience_parent_id_index", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "message_context_id", null: false
    t.bigint "author_id", null: false
    t.text "content"
    t.text "content_delta"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "status", limit: 255, default: "sent", null: false
  end

  create_table "non_federal_partners", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.string "name", limit: 255
  end

  create_table "oban_jobs", comment: "12", force: :cascade do |t|
    t.enum "state", default: "available", null: false, enum_type: "oban_job_state"
    t.text "queue", default: "default", null: false
    t.text "worker", null: false
    t.jsonb "args", default: {}, null: false
    t.jsonb "errors", null: false, array: true
    t.integer "attempt", default: 0, null: false
    t.integer "max_attempts", default: 20, null: false
    t.datetime "inserted_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "scheduled_at", precision: nil, default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "attempted_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.text "attempted_by", array: true
    t.datetime "discarded_at", precision: nil
    t.integer "priority", default: 0, null: false
    t.string "tags", limit: 255, array: true
    t.jsonb "meta", default: {}
    t.datetime "cancelled_at", precision: nil
    t.index ["args"], name: "oban_jobs_args_index", using: :gin
    t.index ["meta"], name: "oban_jobs_meta_index", using: :gin
    t.index ["state", "queue", "priority", "scheduled_at", "id"], name: "oban_jobs_state_queue_priority_scheduled_at_id_index"
    t.check_constraint "attempt >= 0 AND attempt <= max_attempts", name: "attempt_range"
    t.check_constraint "char_length(queue) > 0 AND char_length(queue) < 128", name: "queue_length"
    t.check_constraint "char_length(worker) > 0 AND char_length(worker) < 128", name: "worker_length"
    t.check_constraint "max_attempts > 0", name: "positive_max_attempts"
    t.check_constraint "priority >= 0", name: "non_negative_priority", validate: false
  end

  create_table "oban_peers", primary_key: "name", id: :text, force: :cascade do |t|
    t.text "node", null: false
    t.datetime "started_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
  end

  create_table "phase_winners", id: :bigint, default: -> { "nextval('winners_id_seq'::regclass)" }, force: :cascade do |t|
    t.bigint "phase_id"
    t.uuid "uuid", null: false
    t.string "status", limit: 255
    t.text "overview"
    t.text "overview_delta"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.uuid "overview_image_key"
    t.string "overview_image_extension", limit: 255
    t.index ["phase_id"], name: "winners_phase_id_index", unique: true
  end

  create_table "phases", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.uuid "uuid", null: false
    t.string "title", limit: 255
    t.datetime "start_date", precision: 0
    t.datetime "end_date", precision: 0
    t.boolean "open_to_submissions"
    t.text "judging_criteria"
    t.text "judging_criteria_delta"
    t.text "how_to_enter"
    t.text "how_to_enter_delta"
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "saved_challenges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["user_id", "challenge_id"], name: "saved_challenges_user_id_challenge_id_index", unique: true
  end

  create_table "security_log", force: :cascade do |t|
    t.string "action", limit: 255, null: false
    t.jsonb "details"
    t.bigint "originator_id"
    t.string "originator_role", limit: 255
    t.string "originator_identifier", limit: 255
    t.integer "target_id"
    t.string "target_type", limit: 255
    t.string "target_identifier", limit: 255
    t.datetime "logged_at", precision: 0, null: false
    t.string "originator_remote_ip", limit: 255
  end

  create_table "site_content", force: :cascade do |t|
    t.string "section", limit: 255
    t.text "content"
    t.text "content_delta"
    t.datetime "start_date", precision: 0
    t.datetime "end_date", precision: 0
    t.index ["section"], name: "site_content_section_index", unique: true
  end

  create_table "submission_documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "submission_id"
    t.string "filename", limit: 255, null: false
    t.uuid "key", null: false
    t.string "extension", limit: 255, null: false
    t.string "name", limit: 255
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "submission_exports", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.jsonb "phase_ids"
    t.string "judging_status", limit: 255
    t.string "format", limit: 255
    t.string "status", limit: 255
    t.uuid "key", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "submission_invites", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.text "message"
    t.text "message_delta"
    t.string "status", limit: 255
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "submitter_id", null: false
    t.bigint "challenge_id", null: false
    t.string "title", limit: 255
    t.text "brief_description"
    t.text "description"
    t.string "external_url", limit: 255
    t.string "status", limit: 255
    t.datetime "deleted_at", precision: 0
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.bigint "phase_id", null: false
    t.string "judging_status", limit: 255, default: "not_selected"
    t.bigint "manager_id"
    t.boolean "terms_accepted"
    t.boolean "review_verified"
    t.text "description_delta"
    t.text "brief_description_delta"
    t.string "pdf_reference", limit: 255
  end

  create_table "supporting_documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "challenge_id"
    t.uuid "key", null: false
    t.string "extension", limit: 255, null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "filename", limit: 255, null: false
    t.string "section", limit: 255, null: false
    t.string "name", limit: 255
  end

  create_table "timeline_events", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.string "title", limit: 255, null: false
    t.text "body"
    t.date "occurs_on", null: false
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "password_hash", limit: 255
    t.uuid "token"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "phone_number", limit: 255
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.string "email_verification_token", limit: 255
    t.datetime "email_verified_at", precision: 0
    t.string "role", limit: 255, default: "user", null: false
    t.uuid "password_reset_token"
    t.datetime "password_reset_expires_at", precision: 0
    t.boolean "finalized", default: true, null: false
    t.uuid "avatar_key"
    t.string "avatar_extension", limit: 255
    t.boolean "display", default: true, null: false
    t.datetime "terms_of_use", precision: 0
    t.datetime "privacy_guidelines", precision: 0
    t.bigint "agency_id"
    t.datetime "last_active", precision: 0
    t.string "status", limit: 255
    t.boolean "active_session", default: false
    t.string "renewal_request", limit: 255
    t.text "jwt_token"
    t.datetime "recertification_expired_at", precision: 0
    t.index "lower((email)::text)", name: "users_lower_email_index", unique: true
  end

  create_table "winners", force: :cascade do |t|
    t.bigint "phase_winner_id"
    t.string "name", limit: 255
    t.string "place_title", limit: 255
    t.datetime "inserted_at", precision: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.uuid "image_key"
    t.string "image_extension", limit: 255
  end

  add_foreign_key "agencies", "agencies", column: "parent_id", name: "agencies_parent_id_fkey"
  add_foreign_key "agency_members", "agencies", name: "agency_members_agency_id_fkey"
  add_foreign_key "agency_members", "users", name: "agency_members_user_id_fkey"
  add_foreign_key "certification_log", "users", column: "approver_id", name: "certification_log_approver_id_fkey"
  add_foreign_key "certification_log", "users", name: "certification_log_user_id_fkey"
  add_foreign_key "challenge_managers", "challenges", name: "challenge_owners_challenge_id_fkey"
  add_foreign_key "challenge_managers", "users", name: "challenge_owners_user_id_fkey"
  add_foreign_key "challenges", "agencies", column: "sub_agency_id", name: "challenges_sub_agency_id_fkey"
  add_foreign_key "challenges", "agencies", name: "challenges_agency_id_fkey"
  add_foreign_key "challenges", "users", name: "challenges_user_id_fkey"
  add_foreign_key "federal_partners", "agencies", column: "sub_agency_id", name: "federal_partners_sub_agency_id_fkey"
  add_foreign_key "federal_partners", "agencies", name: "federal_partners_agency_id_fkey"
  add_foreign_key "federal_partners", "challenges", name: "federal_partners_challenge_id_fkey"
  add_foreign_key "message_context_statuses", "message_contexts", name: "message_context_statuses_message_context_id_fkey"
  add_foreign_key "message_context_statuses", "users", name: "message_context_statuses_user_id_fkey"
  add_foreign_key "message_contexts", "message_contexts", column: "parent_id", name: "message_contexts_parent_id_fkey"
  add_foreign_key "message_contexts", "messages", column: "last_message_id", name: "message_contexts_last_message_id_fkey"
  add_foreign_key "messages", "message_contexts", name: "messages_message_context_id_fkey"
  add_foreign_key "messages", "users", column: "author_id", name: "messages_author_id_fkey"
  add_foreign_key "non_federal_partners", "challenges", name: "non_federal_partners_challenge_id_fkey"
  add_foreign_key "phase_winners", "phases", name: "winners_phase_id_fkey"
  add_foreign_key "phases", "challenges", name: "phases_challenge_id_fkey"
  add_foreign_key "saved_challenges", "challenges", name: "saved_challenges_challenge_id_fkey"
  add_foreign_key "saved_challenges", "users", name: "saved_challenges_user_id_fkey"
  add_foreign_key "security_log", "users", column: "originator_id", name: "security_log_originator_id_fkey"
  add_foreign_key "submission_documents", "submissions", name: "solution_documents_solution_id_fkey"
  add_foreign_key "submission_documents", "users", name: "solution_documents_user_id_fkey"
  add_foreign_key "submission_exports", "challenges", name: "submission_exports_challenge_id_fkey"
  add_foreign_key "submission_invites", "submissions", name: "submission_invites_solution_id_fkey"
  add_foreign_key "submissions", "challenges", name: "solutions_challenge_id_fkey"
  add_foreign_key "submissions", "phases", name: "solutions_phase_id_fkey"
  add_foreign_key "submissions", "users", column: "manager_id", name: "solutions_manager_id_fkey"
  add_foreign_key "submissions", "users", column: "submitter_id", name: "solutions_submitter_id_fkey"
  add_foreign_key "supporting_documents", "challenges", name: "supporting_documents_challenge_id_fkey"
  add_foreign_key "supporting_documents", "users", name: "supporting_documents_user_id_fkey"
  add_foreign_key "timeline_events", "challenges", name: "timeline_events_challenge_id_fkey"
  add_foreign_key "users", "agencies", name: "users_agency_id_fkey"
  add_foreign_key "winners", "phase_winners", name: "winners_phase_winner_id_fkey"
end
