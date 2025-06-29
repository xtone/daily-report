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

ActiveRecord::Schema[7.0].define(version: 2025_06_29_094804) do
  create_table "bills", charset: "utf8", force: :cascade do |t|
    t.bigint "estimate_id"
    t.string "serial_no", null: false
    t.string "subject", null: false
    t.integer "amount", default: 0
    t.date "claimed_on"
    t.string "filename", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["estimate_id"], name: "index_bills_on_estimate_id"
    t.index ["serial_no"], name: "index_bills_on_serial_no", unique: true
  end

  create_table "estimates", charset: "utf8", force: :cascade do |t|
    t.bigint "project_id"
    t.string "serial_no", null: false
    t.string "subject", null: false
    t.integer "amount", default: 0
    t.float "director_manday", default: 0.0
    t.float "engineer_manday", default: 0.0
    t.float "designer_manday", default: 0.0
    t.float "other_manday", default: 0.0
    t.integer "cost", default: 0
    t.date "estimated_on"
    t.string "filename", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_id"], name: "index_estimates_on_project_id"
    t.index ["serial_no"], name: "index_estimates_on_serial_no", unique: true
  end

  create_table "operations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "report_id"
    t.integer "project_id"
    t.integer "workload"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_id"], name: "index_operations_on_project_id"
    t.index ["report_id"], name: "index_operations_on_report_id"
  end

  create_table "projects", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.string "name_reading"
    t.integer "category", default: 0, null: false
    t.boolean "hidden", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_projects_on_code", unique: true
  end

  create_table "reports", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.date "worked_in"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "user_projects", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.index ["project_id"], name: "index_user_projects_on_project_id"
    t.index ["user_id", "project_id"], name: "index_user_projects_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_user_projects_on_user_id"
  end

  create_table "user_role_associations", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "user_role_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "user_role_id"], name: "index_user_role_associations_on_user_id_and_user_role_id", unique: true
    t.index ["user_id"], name: "index_user_role_associations_on_user_id"
    t.index ["user_role_id"], name: "index_user_role_associations_on_user_role_id"
  end

  create_table "user_roles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "role"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at", precision: nil
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "division", default: 0, null: false
    t.date "began_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "user_projects", "projects"
  add_foreign_key "user_projects", "users"
  add_foreign_key "user_role_associations", "user_roles"
  add_foreign_key "user_role_associations", "users"
end
