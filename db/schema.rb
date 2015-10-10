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

ActiveRecord::Schema.define(version: 20151010071726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role",                   default: 0
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "contract_files", force: :cascade do |t|
    t.integer  "sub_company_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "contract"
    t.integer  "role",           default: 0
  end

  add_index "contract_files", ["sub_company_id"], name: "index_contract_files_on_sub_company_id", using: :btree

  create_table "engineering_corporations", force: :cascade do |t|
    t.integer  "nest_index"
    t.text     "name"
    t.date     "start_date"
    t.date     "project_date"
    t.text     "project_name"
    t.money    "project_amount",        scale: 2
    t.money    "admin_amount",          scale: 2
    t.money    "total_amount",          scale: 2
    t.date     "income_date"
    t.money    "income_amount",         scale: 2
    t.date     "outcome_date"
    t.text     "outcome_referee"
    t.money    "outcome_amount",        scale: 2
    t.text     "proof"
    t.money    "actual_project_amount", scale: 2
    t.money    "actual_admin_amount",   scale: 2
    t.boolean  "already_get_contract"
    t.boolean  "already_sign_dispatch"
    t.text     "remark"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "main_index"
  end

  add_index "engineering_corporations", ["actual_admin_amount"], name: "index_engineering_corporations_on_actual_admin_amount", using: :btree
  add_index "engineering_corporations", ["actual_project_amount"], name: "index_engineering_corporations_on_actual_project_amount", using: :btree
  add_index "engineering_corporations", ["admin_amount"], name: "index_engineering_corporations_on_admin_amount", using: :btree
  add_index "engineering_corporations", ["already_get_contract"], name: "index_engineering_corporations_on_already_get_contract", using: :btree
  add_index "engineering_corporations", ["already_sign_dispatch"], name: "index_engineering_corporations_on_already_sign_dispatch", using: :btree
  add_index "engineering_corporations", ["income_amount"], name: "index_engineering_corporations_on_income_amount", using: :btree
  add_index "engineering_corporations", ["income_date"], name: "index_engineering_corporations_on_income_date", using: :btree
  add_index "engineering_corporations", ["name"], name: "index_engineering_corporations_on_name", using: :btree
  add_index "engineering_corporations", ["outcome_amount"], name: "index_engineering_corporations_on_outcome_amount", using: :btree
  add_index "engineering_corporations", ["outcome_date"], name: "index_engineering_corporations_on_outcome_date", using: :btree
  add_index "engineering_corporations", ["outcome_referee"], name: "index_engineering_corporations_on_outcome_referee", using: :btree
  add_index "engineering_corporations", ["project_amount"], name: "index_engineering_corporations_on_project_amount", using: :btree
  add_index "engineering_corporations", ["project_date"], name: "index_engineering_corporations_on_project_date", using: :btree
  add_index "engineering_corporations", ["project_name"], name: "index_engineering_corporations_on_project_name", using: :btree
  add_index "engineering_corporations", ["proof"], name: "index_engineering_corporations_on_proof", using: :btree
  add_index "engineering_corporations", ["start_date"], name: "index_engineering_corporations_on_start_date", using: :btree
  add_index "engineering_corporations", ["total_amount"], name: "index_engineering_corporations_on_total_amount", using: :btree

  create_table "engineering_corporations_sub_companies", id: false, force: :cascade do |t|
    t.integer "engineering_corporation_id", null: false
    t.integer "sub_company_id",             null: false
  end

  add_index "engineering_corporations_sub_companies", ["engineering_corporation_id", "sub_company_id"], name: "idx_on_engineering_corporation_id_and_sub_company_id", using: :btree
  add_index "engineering_corporations_sub_companies", ["sub_company_id", "engineering_corporation_id"], name: "idx_sub_company_id_and_engineering_corporation_id", using: :btree

  create_table "engineering_staffs", force: :cascade do |t|
    t.integer  "nest_index"
    t.text     "name"
    t.text     "company_name"
    t.text     "identity_card"
    t.date     "birth"
    t.integer  "age"
    t.integer  "gender",                     default: 0
    t.text     "nation"
    t.text     "address"
    t.text     "remark"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "engineering_corporation_id"
  end

  add_index "engineering_staffs", ["address"], name: "index_engineering_staffs_on_address", using: :btree
  add_index "engineering_staffs", ["age"], name: "index_engineering_staffs_on_age", using: :btree
  add_index "engineering_staffs", ["birth"], name: "index_engineering_staffs_on_birth", using: :btree
  add_index "engineering_staffs", ["company_name"], name: "index_engineering_staffs_on_company_name", using: :btree
  add_index "engineering_staffs", ["engineering_corporation_id"], name: "index_engineering_staffs_on_engineering_corporation_id", using: :btree
  add_index "engineering_staffs", ["gender"], name: "index_engineering_staffs_on_gender", using: :btree
  add_index "engineering_staffs", ["identity_card"], name: "index_engineering_staffs_on_identity_card", using: :btree
  add_index "engineering_staffs", ["name"], name: "index_engineering_staffs_on_name", using: :btree
  add_index "engineering_staffs", ["nation"], name: "index_engineering_staffs_on_nation", using: :btree
  add_index "engineering_staffs", ["nest_index"], name: "index_engineering_staffs_on_nest_index", using: :btree
  add_index "engineering_staffs", ["remark"], name: "index_engineering_staffs_on_remark", using: :btree

  create_table "individual_income_tax_bases", force: :cascade do |t|
    t.integer  "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individual_income_taxes", force: :cascade do |t|
    t.integer  "grade"
    t.integer  "tax_range_start"
    t.integer  "tax_range_end"
    t.decimal  "rate",            precision: 8, scale: 2
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "insurance_fund_rates", force: :cascade do |t|
    t.text     "name"
    t.decimal  "pension",            precision: 8, scale: 4
    t.decimal  "unemployment",       precision: 8, scale: 4
    t.decimal  "medical",            precision: 8, scale: 4
    t.decimal  "injury",             precision: 8, scale: 4
    t.decimal  "birth",              precision: 8, scale: 4
    t.decimal  "house_accumulation", precision: 8, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "labor_contracts", force: :cascade do |t|
    t.integer  "contract_type"
    t.boolean  "in_contract"
    t.date     "contract_start_date"
    t.date     "contract_end_date"
    t.date     "arrive_current_company_at"
    t.boolean  "has_social_insurance"
    t.boolean  "has_medical_insurance"
    t.date     "current_social_insurance_start_date"
    t.date     "current_medical_insurance_start_date"
    t.decimal  "social_insurance_base",                precision: 8, scale: 2
    t.decimal  "medical_insurance_base",               precision: 8, scale: 2
    t.decimal  "house_accumulation_base",              precision: 8, scale: 2
    t.text     "social_insurance_serial"
    t.text     "medical_insurance_serial"
    t.text     "medical_insurance_card"
    t.date     "backup_date"
    t.text     "backup_place"
    t.text     "work_place"
    t.text     "work_type"
    t.date     "release_date"
    t.date     "social_insurance_release_date"
    t.date     "medical_insurance_release_date"
    t.text     "remark"
    t.integer  "sub_company_id"
    t.integer  "normal_corporation_id"
    t.integer  "normal_staff_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "labor_contracts", ["normal_corporation_id"], name: "index_labor_contracts_on_normal_corporation_id", using: :btree
  add_index "labor_contracts", ["normal_staff_id"], name: "index_labor_contracts_on_normal_staff_id", using: :btree
  add_index "labor_contracts", ["sub_company_id"], name: "index_labor_contracts_on_sub_company_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "normal_corporations", force: :cascade do |t|
    t.text     "name"
    t.text     "license"
    t.text     "taxpayer_serial"
    t.text     "organization_serial"
    t.text     "corporate_name"
    t.text     "address"
    t.text     "account"
    t.text     "account_bank"
    t.text     "contact"
    t.text     "telephone"
    t.date     "contract_due_time"
    t.money    "contract_amount",                   scale: 2
    t.integer  "admin_charge_type",                           default: 0
    t.decimal  "admin_charge_amount", precision: 8, scale: 2
    t.date     "expense_date"
    t.integer  "stuff_count"
    t.integer  "insurance_count"
    t.text     "remark"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "normal_corporations", ["account"], name: "index_normal_corporations_on_account", using: :btree
  add_index "normal_corporations", ["account_bank"], name: "index_normal_corporations_on_account_bank", using: :btree
  add_index "normal_corporations", ["address"], name: "index_normal_corporations_on_address", using: :btree
  add_index "normal_corporations", ["admin_charge_amount"], name: "index_normal_corporations_on_admin_charge_amount", using: :btree
  add_index "normal_corporations", ["admin_charge_type"], name: "index_normal_corporations_on_admin_charge_type", using: :btree
  add_index "normal_corporations", ["contact"], name: "index_normal_corporations_on_contact", using: :btree
  add_index "normal_corporations", ["contract_amount"], name: "index_normal_corporations_on_contract_amount", using: :btree
  add_index "normal_corporations", ["contract_due_time"], name: "index_normal_corporations_on_contract_due_time", using: :btree
  add_index "normal_corporations", ["corporate_name"], name: "index_normal_corporations_on_corporate_name", using: :btree
  add_index "normal_corporations", ["expense_date"], name: "index_normal_corporations_on_expense_date", using: :btree
  add_index "normal_corporations", ["insurance_count"], name: "index_normal_corporations_on_insurance_count", using: :btree
  add_index "normal_corporations", ["license"], name: "index_normal_corporations_on_license", using: :btree
  add_index "normal_corporations", ["name"], name: "index_normal_corporations_on_name", using: :btree
  add_index "normal_corporations", ["organization_serial"], name: "index_normal_corporations_on_organization_serial", using: :btree
  add_index "normal_corporations", ["stuff_count"], name: "index_normal_corporations_on_stuff_count", using: :btree
  add_index "normal_corporations", ["taxpayer_serial"], name: "index_normal_corporations_on_taxpayer_serial", using: :btree
  add_index "normal_corporations", ["telephone"], name: "index_normal_corporations_on_telephone", using: :btree

  create_table "normal_corporations_sub_companies", id: false, force: :cascade do |t|
    t.integer "normal_corporation_id", null: false
    t.integer "sub_company_id",        null: false
  end

  add_index "normal_corporations_sub_companies", ["normal_corporation_id", "sub_company_id"], name: "idx_on_normal_corporation_id_and_sub_company_id", using: :btree
  add_index "normal_corporations_sub_companies", ["sub_company_id", "normal_corporation_id"], name: "idx_sub_company_id_and_normal_corporation_id", using: :btree

  create_table "normal_staffs", force: :cascade do |t|
    t.text     "nest_index"
    t.text     "name"
    t.text     "account"
    t.text     "account_bank"
    t.text     "identity_card"
    t.date     "birth"
    t.integer  "age"
    t.integer  "gender",                      default: 0
    t.text     "nation"
    t.text     "grade"
    t.text     "address"
    t.text     "telephone"
    t.date     "social_insurance_start_date"
    t.boolean  "in_service"
    t.text     "remark"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "normal_corporation_id"
  end

  add_index "normal_staffs", ["account"], name: "index_normal_staffs_on_account", using: :btree
  add_index "normal_staffs", ["account_bank"], name: "index_normal_staffs_on_account_bank", using: :btree
  add_index "normal_staffs", ["address"], name: "index_normal_staffs_on_address", using: :btree
  add_index "normal_staffs", ["age"], name: "index_normal_staffs_on_age", using: :btree
  add_index "normal_staffs", ["birth"], name: "index_normal_staffs_on_birth", using: :btree
  add_index "normal_staffs", ["gender"], name: "index_normal_staffs_on_gender", using: :btree
  add_index "normal_staffs", ["grade"], name: "index_normal_staffs_on_grade", using: :btree
  add_index "normal_staffs", ["identity_card"], name: "index_normal_staffs_on_identity_card", using: :btree
  add_index "normal_staffs", ["in_service"], name: "index_normal_staffs_on_in_service", using: :btree
  add_index "normal_staffs", ["name"], name: "index_normal_staffs_on_name", using: :btree
  add_index "normal_staffs", ["nation"], name: "index_normal_staffs_on_nation", using: :btree
  add_index "normal_staffs", ["nest_index"], name: "index_normal_staffs_on_nest_index", using: :btree
  add_index "normal_staffs", ["normal_corporation_id"], name: "index_normal_staffs_on_normal_corporation_id", using: :btree
  add_index "normal_staffs", ["remark"], name: "index_normal_staffs_on_remark", using: :btree
  add_index "normal_staffs", ["social_insurance_start_date"], name: "index_normal_staffs_on_social_insurance_start_date", using: :btree
  add_index "normal_staffs", ["telephone"], name: "index_normal_staffs_on_telephone", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",                       precision: 8, scale: 2
    t.decimal  "annual_reward",                        precision: 8, scale: 2
    t.decimal  "pension_personal",                     precision: 8, scale: 2
    t.decimal  "pension_margin_personal",              precision: 8, scale: 2
    t.decimal  "unemployment_personal",                precision: 8, scale: 2
    t.decimal  "unemployment_margin_personal",         precision: 8, scale: 2
    t.decimal  "medical_personal",                     precision: 8, scale: 2
    t.decimal  "medical_margin_personal",              precision: 8, scale: 2
    t.decimal  "house_accumulation_personal",          precision: 8, scale: 2
    t.decimal  "big_amount_personal",                  precision: 8, scale: 2
    t.decimal  "income_tax",                           precision: 8, scale: 2
    t.decimal  "salary_card_addition",                 precision: 8, scale: 2
    t.decimal  "medical_scan_addition",                precision: 8, scale: 2
    t.decimal  "salary_pre_deduct_addition",           precision: 8, scale: 2
    t.decimal  "insurance_pre_deduct_addition",        precision: 8, scale: 2
    t.decimal  "physical_exam_addition",               precision: 8, scale: 2
    t.decimal  "total_personal",                       precision: 8, scale: 2
    t.decimal  "salary_in_fact",                       precision: 8, scale: 2
    t.decimal  "pension_company",                      precision: 8, scale: 2
    t.decimal  "pension_margin_company",               precision: 8, scale: 2
    t.decimal  "unemployment_company",                 precision: 8, scale: 2
    t.decimal  "unemployment_margin_company",          precision: 8, scale: 2
    t.decimal  "medical_company",                      precision: 8, scale: 2
    t.decimal  "medical_margin_company",               precision: 8, scale: 2
    t.decimal  "injury_company",                       precision: 8, scale: 2
    t.decimal  "injury_margin_company",                precision: 8, scale: 2
    t.decimal  "birth_company",                        precision: 8, scale: 2
    t.decimal  "birth_margin_company",                 precision: 8, scale: 2
    t.decimal  "accident_company",                     precision: 8, scale: 2
    t.decimal  "house_accumulation_company",           precision: 8, scale: 2
    t.decimal  "total_company",                        precision: 8, scale: 2
    t.decimal  "social_insurance_to_salary_deserve",   precision: 8, scale: 2
    t.decimal  "medical_insurance_to_salary_deserve",  precision: 8, scale: 2
    t.decimal  "house_accumulation_to_salary_deserve", precision: 8, scale: 2
    t.decimal  "social_insurance_to_pre_deduct",       precision: 8, scale: 2
    t.decimal  "medical_insurance_to_pre_deduct",      precision: 8, scale: 2
    t.decimal  "house_accumulation_to_pre_deduct",     precision: 8, scale: 2
    t.text     "transfer_fund_to_person"
    t.text     "transfer_fund_to_account"
    t.decimal  "admin_amount",                         precision: 8, scale: 2
    t.decimal  "total_sum",                            precision: 8, scale: 2
    t.decimal  "total_sum_with_admin_amount",          precision: 8, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "salary_table_id"
    t.integer  "normal_staff_id"
  end

  add_index "salary_items", ["normal_staff_id"], name: "index_salary_items_on_normal_staff_id", using: :btree
  add_index "salary_items", ["salary_table_id"], name: "index_salary_items_on_salary_table_id", using: :btree

  create_table "salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "normal_corporation_id"
  end

  add_index "salary_tables", ["name"], name: "index_salary_tables_on_name", using: :btree
  add_index "salary_tables", ["normal_corporation_id"], name: "index_salary_tables_on_normal_corporation_id", using: :btree

  create_table "sub_companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "contract_templates", default: [],              array: true
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "contract_files", "sub_companies"
  add_foreign_key "engineering_staffs", "engineering_corporations"
  add_foreign_key "labor_contracts", "normal_corporations"
  add_foreign_key "labor_contracts", "normal_staffs"
  add_foreign_key "labor_contracts", "sub_companies"
  add_foreign_key "normal_staffs", "normal_corporations"
  add_foreign_key "salary_items", "normal_staffs"
  add_foreign_key "salary_items", "salary_tables"
  add_foreign_key "salary_tables", "normal_corporations"
end
