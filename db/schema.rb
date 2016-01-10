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

ActiveRecord::Schema.define(version: 20160110144620) do

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

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

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
    t.text     "name"
    t.integer  "status",                 default: 0
  end

  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "audition_items", force: :cascade do |t|
    t.integer  "auditable_id"
    t.text     "auditable_type"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "status",         default: 0
  end

  create_table "big_contracts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "sub_company_id"
    t.integer  "engineering_corp_id"
    t.text     "contract"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "enable",              default: false
  end

  add_index "big_contracts", ["engineering_corp_id"], name: "index_big_contracts_on_engineering_corp_id", using: :btree
  add_index "big_contracts", ["sub_company_id"], name: "index_big_contracts_on_sub_company_id", using: :btree

  create_table "contract_files", force: :cascade do |t|
    t.text     "contract"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "busi_contract_id"
    t.string   "busi_contract_type"
  end

  add_index "contract_files", ["busi_contract_type", "busi_contract_id"], name: "idx_busi_contract_id_and_type", using: :btree

  create_table "contract_templates", force: :cascade do |t|
    t.text     "contract"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "sub_company_id"
  end

  add_index "contract_templates", ["sub_company_id"], name: "index_contract_templates_on_sub_company_id", using: :btree

  create_table "engineering_big_table_salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",              precision: 8, scale: 2
    t.decimal  "pension_personal",            precision: 8, scale: 2
    t.decimal  "unemployment_personal",       precision: 8, scale: 2
    t.decimal  "medical_personal",            precision: 8, scale: 2
    t.decimal  "total_personal",              precision: 8, scale: 2
    t.decimal  "salary_in_fact",              precision: 8, scale: 2
    t.decimal  "pension_company",             precision: 8, scale: 2
    t.decimal  "unemployment_company",        precision: 8, scale: 2
    t.decimal  "medical_company",             precision: 8, scale: 2
    t.decimal  "injury_company",              precision: 8, scale: 2
    t.decimal  "birth_company",               precision: 8, scale: 2
    t.decimal  "total_company",               precision: 8, scale: 2
    t.decimal  "total_sum",                   precision: 8, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_big_table_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_big_table_salary_items_of_table", using: :btree
  add_index "engineering_big_table_salary_items", ["engineering_staff_id"], name: "idx_engineering_big_table_salary_items_of_staff", using: :btree

  create_table "engineering_big_table_salary_table_references", force: :cascade do |t|
    t.text     "url"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "engineering_salary_table_id"
  end

  add_index "engineering_big_table_salary_table_references", ["engineering_salary_table_id"], name: "idx_engineering_big_table_reference_of_salary_table", using: :btree

  create_table "engineering_company_medical_insurance_amounts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount",     precision: 8, scale: 2
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "remark"
  end

  create_table "engineering_company_social_insurance_amounts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount",     precision: 8, scale: 2
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "remark"
  end

  create_table "engineering_contract_files", force: :cascade do |t|
    t.integer  "role"
    t.text     "contract"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "engi_contract_id"
    t.string   "engi_contract_type"
  end

  add_index "engineering_contract_files", ["engi_contract_type", "engi_contract_id"], name: "idx_engi_contract_id_and_type", using: :btree

  create_table "engineering_corps", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "remark"
  end

  create_table "engineering_customers", force: :cascade do |t|
    t.text     "name"
    t.text     "telephone"
    t.text     "identity_card"
    t.text     "bank_account"
    t.text     "bank_name",          default: "建设银行"
    t.text     "bank_opening_place"
    t.text     "remark"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "nest_index"
  end

  add_index "engineering_customers", ["nest_index"], name: "index_engineering_customers_on_nest_index", using: :btree

  create_table "engineering_dong_fang_salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",              precision: 8, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_dong_fang_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_dong_fang_salary_items_of_table", using: :btree
  add_index "engineering_dong_fang_salary_items", ["engineering_staff_id"], name: "idx_engineering_dong_fang_salary_items_of_staff", using: :btree

  create_table "engineering_income_items", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                 precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "engineering_project_id"
  end

  add_index "engineering_income_items", ["engineering_project_id"], name: "index_engineering_income_items_on_engineering_project_id", using: :btree

  create_table "engineering_normal_salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",              precision: 8, scale: 2
    t.decimal  "social_insurance",            precision: 8, scale: 2
    t.decimal  "medical_insurance",           precision: 8, scale: 2
    t.decimal  "total_insurance",             precision: 8, scale: 2
    t.decimal  "salary_in_fact",              precision: 8, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_normal_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_normal_salary_items_of_table", using: :btree
  add_index "engineering_normal_salary_items", ["engineering_staff_id"], name: "index_engineering_normal_salary_items_on_engineering_staff_id", using: :btree

  create_table "engineering_normal_with_tax_salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",              precision: 8, scale: 2
    t.decimal  "social_insurance",            precision: 8, scale: 2
    t.decimal  "medical_insurance",           precision: 8, scale: 2
    t.decimal  "total_insurance",             precision: 8, scale: 2
    t.decimal  "total_amount",                precision: 8, scale: 2
    t.decimal  "tax",                         precision: 8, scale: 2
    t.decimal  "salary_in_fact",              precision: 8, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_normal_with_tax_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_normal_with_tax_salary_items_of_table", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["engineering_staff_id"], name: "idx_engineering_normal_with_tax_salary_items_of_staff", using: :btree

  create_table "engineering_outcome_items", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                 precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "engineering_project_id"
    t.text     "persons",                                         default: [],              array: true
    t.text     "bank",                                            default: [],              array: true
    t.text     "address",                                         default: [],              array: true
    t.text     "account",                                         default: [],              array: true
  end

  add_index "engineering_outcome_items", ["engineering_project_id"], name: "index_engineering_outcome_items_on_engineering_project_id", using: :btree

  create_table "engineering_projects", force: :cascade do |t|
    t.text     "name"
    t.date     "start_date"
    t.date     "project_start_date"
    t.date     "project_end_date"
    t.text     "project_range"
    t.decimal  "project_amount",          precision: 12, scale: 2
    t.decimal  "admin_amount",            precision: 12, scale: 2
    t.decimal  "total_amount",            precision: 12, scale: 2
    t.date     "income_date"
    t.decimal  "income_amount",           precision: 12, scale: 2
    t.date     "outcome_date"
    t.text     "outcome_referee"
    t.decimal  "outcome_amount",          precision: 12, scale: 2
    t.text     "proof"
    t.boolean  "already_sign_dispatch"
    t.text     "remark"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "engineering_customer_id"
    t.integer  "engineering_corp_id"
    t.integer  "status",                                           default: 0
    t.integer  "sub_company_id"
    t.integer  "nest_index"
  end

  add_index "engineering_projects", ["engineering_corp_id"], name: "index_engineering_projects_on_engineering_corp_id", using: :btree
  add_index "engineering_projects", ["engineering_customer_id", "nest_index"], name: "idx_customer_and_nest_index_on_engi_project", using: :btree
  add_index "engineering_projects", ["engineering_customer_id"], name: "index_engineering_projects_on_engineering_customer_id", using: :btree
  add_index "engineering_projects", ["nest_index"], name: "index_engineering_projects_on_nest_index", using: :btree
  add_index "engineering_projects", ["status"], name: "index_engineering_projects_on_status", using: :btree
  add_index "engineering_projects", ["sub_company_id"], name: "index_engineering_projects_on_sub_company_id", using: :btree

  create_table "engineering_projects_staffs", id: false, force: :cascade do |t|
    t.integer "engineering_project_id", null: false
    t.integer "engineering_staff_id",   null: false
  end

  add_index "engineering_projects_staffs", ["engineering_project_id", "engineering_staff_id"], name: "idx_on_engineering_project_id_and_engineering_staff_id", using: :btree
  add_index "engineering_projects_staffs", ["engineering_staff_id", "engineering_project_id"], name: "idx_on_engineering_staff_id_and_engineering_project_id", using: :btree

  create_table "engineering_salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "type"
    t.text     "remark"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "engineering_project_id"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount",                 precision: 12, scale: 2
  end

  add_index "engineering_salary_tables", ["engineering_project_id"], name: "index_engineering_salary_tables_on_engineering_project_id", using: :btree

  create_table "engineering_staffs", force: :cascade do |t|
    t.text     "name"
    t.text     "identity_card"
    t.date     "birth"
    t.integer  "age"
    t.integer  "gender",                  default: 0
    t.text     "remark"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "engineering_customer_id"
    t.boolean  "enable",                  default: true
    t.text     "alias_name"
    t.text     "seal_index"
  end

  add_index "engineering_staffs", ["age"], name: "index_engineering_staffs_on_age", using: :btree
  add_index "engineering_staffs", ["birth"], name: "index_engineering_staffs_on_birth", using: :btree
  add_index "engineering_staffs", ["enable"], name: "index_engineering_staffs_on_enable", using: :btree
  add_index "engineering_staffs", ["engineering_customer_id"], name: "index_engineering_staffs_on_engineering_customer_id", using: :btree
  add_index "engineering_staffs", ["gender"], name: "index_engineering_staffs_on_gender", using: :btree
  add_index "engineering_staffs", ["identity_card"], name: "index_engineering_staffs_on_identity_card", using: :btree
  add_index "engineering_staffs", ["name"], name: "index_engineering_staffs_on_name", using: :btree
  add_index "engineering_staffs", ["remark"], name: "index_engineering_staffs_on_remark", using: :btree
  add_index "engineering_staffs", ["seal_index"], name: "index_engineering_staffs_on_seal_index", using: :btree
  add_index "engineering_staffs", ["updated_at", "enable"], name: "index_engineering_staffs_on_updated_at_and_enable", using: :btree
  add_index "engineering_staffs", ["updated_at"], name: "index_engineering_staffs_on_updated_at", using: :btree

  create_table "guard_salary_items", force: :cascade do |t|
    t.decimal  "income",                precision: 8, scale: 2
    t.decimal  "salary_deserve",        precision: 8, scale: 2
    t.decimal  "festival",              precision: 8, scale: 2
    t.decimal  "overtime",              precision: 8, scale: 2
    t.decimal  "dress_return",          precision: 8, scale: 2
    t.decimal  "salary_deserve_total",  precision: 8, scale: 2
    t.decimal  "physical_exam_deduct",  precision: 8, scale: 2
    t.decimal  "dress_deduct",          precision: 8, scale: 2
    t.decimal  "work_exam_deduct",      precision: 8, scale: 2
    t.decimal  "other_deduct",          precision: 8, scale: 2
    t.decimal  "total_deduct",          precision: 8, scale: 2
    t.decimal  "salary_in_fact",        precision: 8, scale: 2
    t.decimal  "accident_insurance",    precision: 8, scale: 2
    t.decimal  "total",                 precision: 8, scale: 2
    t.decimal  "balance",               precision: 8, scale: 2
    t.integer  "normal_staff_id"
    t.integer  "guard_salary_table_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "remark"
  end

  add_index "guard_salary_items", ["guard_salary_table_id"], name: "index_guard_salary_items_on_guard_salary_table_id", using: :btree
  add_index "guard_salary_items", ["normal_staff_id"], name: "index_guard_salary_items_on_normal_staff_id", using: :btree

  create_table "guard_salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.integer  "normal_corporation_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "guard_salary_tables", ["normal_corporation_id"], name: "index_guard_salary_tables_on_normal_corporation_id", using: :btree

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

  create_table "invoices", force: :cascade do |t|
    t.date     "release_date"
    t.text     "encoding"
    t.text     "payer"
    t.text     "project_name"
    t.string   "amount"
    t.decimal  "total_amount",    precision: 8, scale: 2
    t.text     "contact_person"
    t.text     "refund_person"
    t.text     "refund_bank"
    t.text     "refund_account"
    t.date     "income_date"
    t.date     "refund_date"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "remark"
    t.integer  "invoicable_id"
    t.string   "invoicable_type"
  end

  add_index "invoices", ["invoicable_type", "invoicable_id"], name: "index_invoices_on_invoicable_type_and_invoicable_id", using: :btree

  create_table "labor_contracts", force: :cascade do |t|
    t.integer  "contract_type"
    t.boolean  "in_contract"
    t.date     "contract_start_date"
    t.date     "contract_end_date"
    t.date     "arrive_current_company_at"
    t.boolean  "has_social_insurance"
    t.boolean  "has_medical_insurance"
    t.boolean  "has_accident_insurance"
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
    t.integer  "normal_corporation_id"
    t.integer  "normal_staff_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "labor_contracts", ["normal_corporation_id"], name: "index_labor_contracts_on_normal_corporation_id", using: :btree
  add_index "labor_contracts", ["normal_staff_id"], name: "index_labor_contracts_on_normal_staff_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "non_full_day_salary_items", force: :cascade do |t|
    t.text     "month"
    t.decimal  "work_hour",                    precision: 8, scale: 2
    t.decimal  "work_wage",                    precision: 8, scale: 2
    t.decimal  "salary_deserve",               precision: 8, scale: 2
    t.decimal  "tax",                          precision: 8, scale: 2
    t.decimal  "other",                        precision: 8, scale: 2
    t.decimal  "salary_in_fact",               precision: 8, scale: 2
    t.decimal  "accident_insurance",           precision: 8, scale: 2
    t.decimal  "admin_amount",                 precision: 8, scale: 2
    t.decimal  "total",                        precision: 8, scale: 2
    t.integer  "normal_staff_id"
    t.text     "remark"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "non_full_day_salary_table_id"
  end

  add_index "non_full_day_salary_items", ["non_full_day_salary_table_id"], name: "index_non_full_day_salary_items_on_non_full_day_salary_table_id", using: :btree
  add_index "non_full_day_salary_items", ["normal_staff_id"], name: "index_non_full_day_salary_items_on_normal_staff_id", using: :btree

  create_table "non_full_day_salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.integer  "normal_corporation_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "non_full_day_salary_tables", ["normal_corporation_id"], name: "index_non_full_day_salary_tables_on_normal_corporation_id", using: :btree

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
    t.money    "contract_amount",                   scale: 2
    t.integer  "admin_charge_type",                           default: 0
    t.decimal  "admin_charge_amount", precision: 8, scale: 2, default: 0.0
    t.date     "expense_date"
    t.text     "remark"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.date     "contract_start_date"
    t.date     "contract_end_date"
    t.text     "full_name"
    t.integer  "sub_company_id"
    t.integer  "status",                                      default: 0
  end

  add_index "normal_corporations", ["account"], name: "index_normal_corporations_on_account", using: :btree
  add_index "normal_corporations", ["account_bank"], name: "index_normal_corporations_on_account_bank", using: :btree
  add_index "normal_corporations", ["address"], name: "index_normal_corporations_on_address", using: :btree
  add_index "normal_corporations", ["admin_charge_amount"], name: "index_normal_corporations_on_admin_charge_amount", using: :btree
  add_index "normal_corporations", ["admin_charge_type"], name: "index_normal_corporations_on_admin_charge_type", using: :btree
  add_index "normal_corporations", ["contact"], name: "index_normal_corporations_on_contact", using: :btree
  add_index "normal_corporations", ["contract_amount"], name: "index_normal_corporations_on_contract_amount", using: :btree
  add_index "normal_corporations", ["contract_end_date"], name: "index_normal_corporations_on_contract_end_date", using: :btree
  add_index "normal_corporations", ["contract_start_date"], name: "index_normal_corporations_on_contract_start_date", using: :btree
  add_index "normal_corporations", ["corporate_name"], name: "index_normal_corporations_on_corporate_name", using: :btree
  add_index "normal_corporations", ["expense_date"], name: "index_normal_corporations_on_expense_date", using: :btree
  add_index "normal_corporations", ["license"], name: "index_normal_corporations_on_license", using: :btree
  add_index "normal_corporations", ["name"], name: "index_normal_corporations_on_name", using: :btree
  add_index "normal_corporations", ["organization_serial"], name: "index_normal_corporations_on_organization_serial", using: :btree
  add_index "normal_corporations", ["status"], name: "index_normal_corporations_on_status", using: :btree
  add_index "normal_corporations", ["sub_company_id"], name: "index_normal_corporations_on_sub_company_id", using: :btree
  add_index "normal_corporations", ["taxpayer_serial"], name: "index_normal_corporations_on_taxpayer_serial", using: :btree
  add_index "normal_corporations", ["telephone"], name: "index_normal_corporations_on_telephone", using: :btree

  create_table "normal_staffs", force: :cascade do |t|
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
    t.integer  "sub_company_id"
    t.integer  "nest_index"
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
  add_index "normal_staffs", ["normal_corporation_id"], name: "index_normal_staffs_on_normal_corporation_id", using: :btree
  add_index "normal_staffs", ["remark"], name: "index_normal_staffs_on_remark", using: :btree
  add_index "normal_staffs", ["social_insurance_start_date"], name: "index_normal_staffs_on_social_insurance_start_date", using: :btree
  add_index "normal_staffs", ["sub_company_id"], name: "index_normal_staffs_on_sub_company_id", using: :btree
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
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
    t.integer  "salary_table_id"
    t.integer  "normal_staff_id"
    t.decimal  "deduct_addition",                      precision: 8, scale: 2
    t.decimal  "salary_deduct_addition",               precision: 8, scale: 2
    t.decimal  "other_deduct_addition",                precision: 8, scale: 2
    t.decimal  "other_personal",                       precision: 8, scale: 2
    t.decimal  "other_company",                        precision: 8, scale: 2
    t.integer  "role",                                                         default: 0
  end

  add_index "salary_items", ["normal_staff_id"], name: "index_salary_items_on_normal_staff_id", using: :btree
  add_index "salary_items", ["role"], name: "index_salary_items_on_role", using: :btree
  add_index "salary_items", ["salary_table_id"], name: "index_salary_items_on_salary_table_id", using: :btree

  create_table "salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "normal_corporation_id"
    t.text     "lai_table"
    t.text     "daka_table"
  end

  add_index "salary_tables", ["name"], name: "index_salary_tables_on_name", using: :btree
  add_index "salary_tables", ["normal_corporation_id"], name: "index_salary_tables_on_normal_corporation_id", using: :btree

  create_table "seal_items", force: :cascade do |t|
    t.integer  "nest_index"
    t.text     "name"
    t.text     "remark"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "seal_table_id"
  end

  add_index "seal_items", ["name"], name: "index_seal_items_on_name", using: :btree
  add_index "seal_items", ["seal_table_id"], name: "index_seal_items_on_seal_table_id", using: :btree

  create_table "seal_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sub_companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "has_engineering_relation"
    t.text     "engi_contract_template"
    t.text     "engi_protocol_template"
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

  add_foreign_key "big_contracts", "engineering_corps"
  add_foreign_key "big_contracts", "sub_companies"
  add_foreign_key "contract_templates", "sub_companies"
  add_foreign_key "engineering_big_table_salary_items", "engineering_salary_tables"
  add_foreign_key "engineering_big_table_salary_items", "engineering_staffs"
  add_foreign_key "engineering_big_table_salary_table_references", "engineering_salary_tables"
  add_foreign_key "engineering_dong_fang_salary_items", "engineering_salary_tables"
  add_foreign_key "engineering_dong_fang_salary_items", "engineering_staffs"
  add_foreign_key "engineering_income_items", "engineering_projects"
  add_foreign_key "engineering_normal_salary_items", "engineering_salary_tables"
  add_foreign_key "engineering_normal_salary_items", "engineering_staffs"
  add_foreign_key "engineering_normal_with_tax_salary_items", "engineering_salary_tables"
  add_foreign_key "engineering_normal_with_tax_salary_items", "engineering_staffs"
  add_foreign_key "engineering_outcome_items", "engineering_projects"
  add_foreign_key "engineering_projects", "engineering_corps"
  add_foreign_key "engineering_projects", "engineering_customers"
  add_foreign_key "engineering_projects", "sub_companies"
  add_foreign_key "engineering_salary_tables", "engineering_projects"
  add_foreign_key "engineering_staffs", "engineering_customers"
  add_foreign_key "guard_salary_items", "guard_salary_tables"
  add_foreign_key "guard_salary_items", "normal_staffs"
  add_foreign_key "guard_salary_tables", "normal_corporations"
  add_foreign_key "labor_contracts", "normal_corporations"
  add_foreign_key "labor_contracts", "normal_staffs"
  add_foreign_key "non_full_day_salary_items", "non_full_day_salary_tables"
  add_foreign_key "non_full_day_salary_items", "normal_staffs"
  add_foreign_key "non_full_day_salary_tables", "normal_corporations"
  add_foreign_key "normal_corporations", "sub_companies"
  add_foreign_key "normal_staffs", "normal_corporations"
  add_foreign_key "normal_staffs", "sub_companies"
  add_foreign_key "salary_items", "normal_staffs"
  add_foreign_key "salary_items", "salary_tables"
  add_foreign_key "salary_tables", "normal_corporations"
  add_foreign_key "seal_items", "seal_tables"
end
