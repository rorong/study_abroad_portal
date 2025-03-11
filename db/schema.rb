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

ActiveRecord::Schema[8.0].define(version: 2025_03_06_125409) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "academic_levels", force: :cascade do |t|
    t.string "level_name"
    t.bigint "education_board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["education_board_id"], name: "index_academic_levels_on_education_board_id"
  end

  create_table "course_requirements", force: :cascade do |t|
    t.bigint "course_id"
    t.boolean "selt_waived_off"
    t.string "type_of_ielts_required"
    t.float "weightage_class_10"
    t.float "weightage_class_12"
    t.float "grad_score_required_3yrs_tier1"
    t.float "grad_score_required_3yrs_tier2"
    t.float "grad_score_required_3yrs_tier3"
    t.float "grad_score_required_4yrs_tier1"
    t.float "grad_score_required_4yrs_tier2"
    t.float "grad_score_required_4yrs_tier3"
    t.float "weightage_grad_score"
    t.integer "num_backlogs_accepted"
    t.float "min_work_experience_years"
    t.float "initial_fee_visa_letter"
    t.boolean "lateral_entry_possible"
    t.boolean "agent_appointment_allowed"
    t.boolean "cv_mandatory"
    t.boolean "lor_mandatory"
    t.boolean "sop_mandatory"
    t.boolean "interview_mandatory"
    t.boolean "sealed_transcript_mandatory"
    t.boolean "attested_docs_mandatory"
    t.boolean "change_of_agent_allowed"
    t.boolean "color_scan_mandatory"
    t.boolean "international_students_allowed"
    t.string "previous_degree_subject"
    t.string "similar_subjects_tags"
    t.boolean "unsubscribed_mode"
    t.datetime "unsubscribed_time"
    t.float "gap_after_class_12_years"
    t.text "doubts_or_observations"
    t.integer "grad_validity_moi_months"
    t.string "moi_restricted_states"
    t.boolean "moi_tier1_accepted"
    t.boolean "moi_tier2_accepted"
    t.boolean "moi_tier3_accepted"
    t.boolean "moi_any_university_accepted"
    t.float "work_experience_factor"
    t.string "fee_currency"
    t.text "admission_process_notes"
    t.integer "gap_after_degree"
    t.integer "previous_academic_grades"
    t.integer "all_rounder_capabilities"
    t.string "gmat_score"
    t.string "gre_score"
    t.string "sat_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_requirements_on_course_id"
  end

  create_table "course_subject_requirements", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "subject_id"
    t.float "min_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_subject_requirements_on_course_id"
    t.index ["subject_id"], name: "index_course_subject_requirements_on_subject_id"
  end

  create_table "course_tags", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_tags_on_course_id"
    t.index ["tag_id"], name: "index_course_tags_on_tag_id"
  end

  create_table "course_test_requirements", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "standardized_test_id"
    t.float "min_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_test_requirements_on_course_id"
    t.index ["standardized_test_id"], name: "index_course_test_requirements_on_standardized_test_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "record_id"
    t.string "name"
    t.string "owner_id"
    t.string "creator_id"
    t.string "modifier_id"
    t.datetime "last_activity_time"
    t.string "layout_id"
    t.datetime "user_modified_time"
    t.datetime "system_modified_time"
    t.datetime "user_related_activity_time"
    t.datetime "system_related_activity_time"
    t.string "record_approval_status"
    t.boolean "is_record_duplicate"
    t.string "course_image"
    t.string "course_weblink"
    t.string "level_of_course"
    t.string "course_code"
    t.string "course_duration"
    t.string "institution_id"
    t.bigint "department_id"
    t.string "title"
    t.float "application_fee"
    t.float "tuition_fee_international"
    t.float "tuition_fee_local"
    t.string "intake"
    t.string "delivery_method"
    t.string "department"
    t.string "internship_period"
    t.string "record_status"
    t.string "current_status"
    t.boolean "locked", default: false
    t.boolean "delete_record", default: false
    t.integer "duration_months"
    t.boolean "international_students_eligible"
    t.boolean "should_delete", default: false
    t.text "module_subjects"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "education_board_id"
    t.index ["course_code"], name: "index_courses_on_course_code"
    t.index ["creator_id"], name: "index_courses_on_creator_id"
    t.index ["department_id"], name: "index_courses_on_department_id"
    t.index ["institution_id"], name: "index_courses_on_institution_id"
    t.index ["modifier_id"], name: "index_courses_on_modifier_id"
    t.index ["name"], name: "index_courses_on_name"
    t.index ["owner_id"], name: "index_courses_on_owner_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "currency_code"
    t.decimal "exchange_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "education_boards", force: :cascade do |t|
    t.string "board_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_name"], name: "index_education_boards_on_board_name"
  end

  create_table "institutions", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_institutions_on_name"
  end

  create_table "remarks", force: :cascade do |t|
    t.string "user_id"
    t.bigint "course_id"
    t.text "remarks_course_desc"
    t.text "remarks_selt"
    t.text "remarks_entry_req"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_remarks_on_course_id"
    t.index ["user_id"], name: "index_remarks_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "user_id"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "standardized_tests", force: :cascade do |t|
    t.string "test_name"
    t.integer "exam_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.bigint "academic_level_id"
    t.bigint "education_board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.index ["academic_level_id"], name: "index_subjects_on_academic_level_id"
    t.index ["department_id"], name: "index_subjects_on_department_id"
    t.index ["education_board_id"], name: "index_subjects_on_education_board_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "email_address"
    t.string "secondary_email"
    t.string "password_digest"
    t.boolean "email_opt_out", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address"
  end

  add_foreign_key "academic_levels", "education_boards"
  add_foreign_key "course_requirements", "courses"
  add_foreign_key "course_subject_requirements", "courses"
  add_foreign_key "course_subject_requirements", "subjects"
  add_foreign_key "course_tags", "courses"
  add_foreign_key "course_tags", "tags"
  add_foreign_key "course_test_requirements", "courses"
  add_foreign_key "course_test_requirements", "standardized_tests"
  add_foreign_key "courses", "departments"
  add_foreign_key "courses", "institutions"
  add_foreign_key "courses", "users", column: "creator_id"
  add_foreign_key "courses", "users", column: "modifier_id"
  add_foreign_key "courses", "users", column: "owner_id"
  add_foreign_key "remarks", "courses"
  add_foreign_key "remarks", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "subjects", "academic_levels"
  add_foreign_key "subjects", "departments"
  add_foreign_key "subjects", "education_boards"
end
