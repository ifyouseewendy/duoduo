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

ActiveRecord::Schema.define(version: 20200318214535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "role",                    default: 0
    t.text     "name"
    t.integer  "status",                  default: 0
    t.text     "visible_sub_company_ids", default: [],              array: true
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
    t.decimal  "salary_deserve",              precision: 12, scale: 2
    t.decimal  "pension_personal",            precision: 12, scale: 2
    t.decimal  "unemployment_personal",       precision: 12, scale: 2
    t.decimal  "medical_personal",            precision: 12, scale: 2
    t.decimal  "total_personal",              precision: 12, scale: 2
    t.decimal  "salary_in_fact",              precision: 12, scale: 2
    t.decimal  "pension_company",             precision: 12, scale: 2
    t.decimal  "unemployment_company",        precision: 12, scale: 2
    t.decimal  "medical_company",             precision: 12, scale: 2
    t.decimal  "injury_company",              precision: 12, scale: 2
    t.decimal  "birth_company",               precision: 12, scale: 2
    t.decimal  "total_company",               precision: 12, scale: 2
    t.decimal  "total_sum",                   precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
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
    t.text     "name"
    t.text     "remark"
  end

  add_index "engineering_big_table_salary_table_references", ["engineering_salary_table_id"], name: "idx_engineering_big_table_reference_of_salary_table", using: :btree

  create_table "engineering_company_medical_insurance_amounts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount",     precision: 12, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "remark"
  end

  create_table "engineering_company_social_insurance_amounts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount",     precision: 12, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
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
    t.decimal  "salary_deserve",              precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
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
    t.decimal  "salary_deserve",              precision: 12, scale: 2
    t.decimal  "social_insurance",            precision: 12, scale: 2
    t.decimal  "medical_insurance",           precision: 12, scale: 2
    t.decimal  "total_insurance",             precision: 12, scale: 2
    t.decimal  "salary_in_fact",              precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_normal_salary_items", ["created_at"], name: "index_engineering_normal_salary_items_on_created_at", using: :btree
  add_index "engineering_normal_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_normal_salary_items_of_table", using: :btree
  add_index "engineering_normal_salary_items", ["engineering_staff_id"], name: "index_engineering_normal_salary_items_on_engineering_staff_id", using: :btree
  add_index "engineering_normal_salary_items", ["medical_insurance"], name: "index_engineering_normal_salary_items_on_medical_insurance", using: :btree
  add_index "engineering_normal_salary_items", ["remark"], name: "index_engineering_normal_salary_items_on_remark", using: :btree
  add_index "engineering_normal_salary_items", ["salary_deserve"], name: "index_engineering_normal_salary_items_on_salary_deserve", using: :btree
  add_index "engineering_normal_salary_items", ["salary_in_fact"], name: "index_engineering_normal_salary_items_on_salary_in_fact", using: :btree
  add_index "engineering_normal_salary_items", ["social_insurance"], name: "index_engineering_normal_salary_items_on_social_insurance", using: :btree
  add_index "engineering_normal_salary_items", ["total_insurance"], name: "index_engineering_normal_salary_items_on_total_insurance", using: :btree

  create_table "engineering_normal_with_tax_salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",              precision: 12, scale: 2
    t.decimal  "social_insurance",            precision: 12, scale: 2
    t.decimal  "medical_insurance",           precision: 12, scale: 2
    t.decimal  "total_insurance",             precision: 12, scale: 2
    t.decimal  "total_amount",                precision: 12, scale: 2
    t.decimal  "tax",                         precision: 12, scale: 2
    t.decimal  "salary_in_fact",              precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "engineering_salary_table_id"
    t.integer  "engineering_staff_id"
  end

  add_index "engineering_normal_with_tax_salary_items", ["created_at"], name: "index_engineering_normal_with_tax_salary_items_on_created_at", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["engineering_salary_table_id"], name: "idx_engineering_normal_with_tax_salary_items_of_table", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["engineering_staff_id"], name: "idx_engineering_normal_with_tax_salary_items_of_staff", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["medical_insurance"], name: "idx_engi_si_with_tax_medical_insurance", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["remark"], name: "index_engineering_normal_with_tax_salary_items_on_remark", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["salary_deserve"], name: "idx_engi_si_with_tax_salary_deserve", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["salary_in_fact"], name: "idx_engi_si_with_tax_salary_in_fact", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["social_insurance"], name: "idx_engi_si_with_tax_social_insurance", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["tax"], name: "index_engineering_normal_with_tax_salary_items_on_tax", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["total_amount"], name: "idx_engi_si_with_tax_total_amount", using: :btree
  add_index "engineering_normal_with_tax_salary_items", ["total_insurance"], name: "idx_engi_si_with_tax_total_insurance", using: :btree

  create_table "engineering_outcome_items", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                 precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "engineering_project_id"
    t.text     "persons",                                         default: [],              array: true
    t.text     "id_numbers",                                      default: [],              array: true
    t.text     "bank",                                            default: [],              array: true
    t.text     "address",                                         default: [],              array: true
    t.text     "account",                                         default: [],              array: true
    t.text     "each_amount",                                     default: [],              array: true
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
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "engineering_customer_id"
    t.integer  "engineering_corp_id"
    t.integer  "status",                                           default: 0
    t.integer  "sub_company_id"
    t.integer  "nest_index"
    t.boolean  "locked",                                           default: false
  end

  add_index "engineering_projects", ["engineering_corp_id"], name: "index_engineering_projects_on_engineering_corp_id", using: :btree
  add_index "engineering_projects", ["engineering_customer_id", "nest_index"], name: "idx_customer_and_nest_index_on_engi_project", using: :btree
  add_index "engineering_projects", ["engineering_customer_id"], name: "index_engineering_projects_on_engineering_customer_id", using: :btree
  add_index "engineering_projects", ["locked"], name: "index_engineering_projects_on_locked", using: :btree
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
    t.text     "attachment"
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
  add_index "engineering_staffs", ["created_at"], name: "index_engineering_staffs_on_created_at", using: :btree
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
    t.integer  "nest_index",                                     default: 0
    t.text     "station"
    t.text     "staff_account"
    t.text     "staff_name"
    t.decimal  "income",                precision: 12, scale: 2, default: 0.0
    t.decimal  "salary_base",           precision: 12, scale: 2, default: 0.0
    t.decimal  "festival",              precision: 12, scale: 2, default: 0.0
    t.decimal  "overtime",              precision: 12, scale: 2, default: 0.0
    t.decimal  "exam",                  precision: 12, scale: 2, default: 0.0
    t.decimal  "duty",                  precision: 12, scale: 2, default: 0.0
    t.decimal  "salary_deserve",        precision: 12, scale: 2, default: 0.0
    t.decimal  "dress_deduct",          precision: 12, scale: 2, default: 0.0
    t.decimal  "physical_exam_deduct",  precision: 12, scale: 2, default: 0.0
    t.decimal  "pre_deduct",            precision: 12, scale: 2, default: 0.0
    t.decimal  "total_deduct",          precision: 12, scale: 2, default: 0.0
    t.decimal  "salary_in_fact",        precision: 12, scale: 2, default: 0.0
    t.decimal  "accident_insurance",    precision: 12, scale: 2, default: 0.0
    t.decimal  "total_sum",             precision: 12, scale: 2, default: 0.0
    t.decimal  "balance",               precision: 12, scale: 2, default: 0.0
    t.text     "remark"
    t.integer  "role",                                           default: 0
    t.integer  "normal_staff_id"
    t.integer  "guard_salary_table_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guard_salary_items", ["accident_insurance"], name: "index_guard_salary_items_on_accident_insurance", using: :btree
  add_index "guard_salary_items", ["balance"], name: "index_guard_salary_items_on_balance", using: :btree
  add_index "guard_salary_items", ["created_at"], name: "index_guard_salary_items_on_created_at", using: :btree
  add_index "guard_salary_items", ["dress_deduct"], name: "index_guard_salary_items_on_dress_deduct", using: :btree
  add_index "guard_salary_items", ["duty"], name: "index_guard_salary_items_on_duty", using: :btree
  add_index "guard_salary_items", ["exam"], name: "index_guard_salary_items_on_exam", using: :btree
  add_index "guard_salary_items", ["festival"], name: "index_guard_salary_items_on_festival", using: :btree
  add_index "guard_salary_items", ["guard_salary_table_id"], name: "index_guard_salary_items_on_guard_salary_table_id", using: :btree
  add_index "guard_salary_items", ["income"], name: "index_guard_salary_items_on_income", using: :btree
  add_index "guard_salary_items", ["nest_index", "role"], name: "index_guard_salary_items_on_nest_index_and_role", using: :btree
  add_index "guard_salary_items", ["nest_index"], name: "index_guard_salary_items_on_nest_index", using: :btree
  add_index "guard_salary_items", ["normal_staff_id"], name: "index_guard_salary_items_on_normal_staff_id", using: :btree
  add_index "guard_salary_items", ["overtime"], name: "index_guard_salary_items_on_overtime", using: :btree
  add_index "guard_salary_items", ["physical_exam_deduct"], name: "index_guard_salary_items_on_physical_exam_deduct", using: :btree
  add_index "guard_salary_items", ["pre_deduct"], name: "index_guard_salary_items_on_pre_deduct", using: :btree
  add_index "guard_salary_items", ["remark"], name: "index_guard_salary_items_on_remark", using: :btree
  add_index "guard_salary_items", ["role"], name: "index_guard_salary_items_on_role", using: :btree
  add_index "guard_salary_items", ["salary_base"], name: "index_guard_salary_items_on_salary_base", using: :btree
  add_index "guard_salary_items", ["salary_deserve"], name: "index_guard_salary_items_on_salary_deserve", using: :btree
  add_index "guard_salary_items", ["salary_in_fact"], name: "index_guard_salary_items_on_salary_in_fact", using: :btree
  add_index "guard_salary_items", ["staff_account"], name: "index_guard_salary_items_on_staff_account", using: :btree
  add_index "guard_salary_items", ["staff_name"], name: "index_guard_salary_items_on_staff_name", using: :btree
  add_index "guard_salary_items", ["station"], name: "index_guard_salary_items_on_station", using: :btree
  add_index "guard_salary_items", ["total_deduct"], name: "index_guard_salary_items_on_total_deduct", using: :btree
  add_index "guard_salary_items", ["total_sum"], name: "index_guard_salary_items_on_total_sum", using: :btree
  add_index "guard_salary_items", ["updated_at"], name: "index_guard_salary_items_on_updated_at", using: :btree

  create_table "guard_salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.integer  "normal_corporation_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.date     "start_date"
    t.text     "lai_table"
    t.text     "daka_table"
    t.integer  "status",                                         default: 0
    t.hstore   "audition",                                       default: {}
    t.decimal  "amount",                precision: 12, scale: 2
  end

  add_index "guard_salary_tables", ["amount"], name: "index_guard_salary_tables_on_amount", using: :btree
  add_index "guard_salary_tables", ["created_at"], name: "index_guard_salary_tables_on_created_at", using: :btree
  add_index "guard_salary_tables", ["name"], name: "index_guard_salary_tables_on_name", using: :btree
  add_index "guard_salary_tables", ["normal_corporation_id"], name: "index_guard_salary_tables_on_normal_corporation_id", using: :btree
  add_index "guard_salary_tables", ["start_date"], name: "index_guard_salary_tables_on_start_date", using: :btree
  add_index "guard_salary_tables", ["status"], name: "index_guard_salary_tables_on_status", using: :btree
  add_index "guard_salary_tables", ["updated_at"], name: "index_guard_salary_tables_on_updated_at", using: :btree

  create_table "individual_income_tax_bases", force: :cascade do |t|
    t.integer  "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individual_income_taxes", force: :cascade do |t|
    t.integer  "grade"
    t.integer  "tax_range_start"
    t.integer  "tax_range_end"
    t.decimal  "rate",            precision: 12, scale: 2
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "insurance_fund_rates", force: :cascade do |t|
    t.text     "name"
    t.decimal  "pension",            precision: 12, scale: 2
    t.decimal  "unemployment",       precision: 12, scale: 2
    t.decimal  "medical",            precision: 12, scale: 2
    t.decimal  "injury",             precision: 12, scale: 2
    t.decimal  "birth",              precision: 12, scale: 2
    t.decimal  "house_accumulation", precision: 12, scale: 2
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "invoice_settings", force: :cascade do |t|
    t.integer  "category"
    t.text     "code"
    t.text     "start_encoding"
    t.integer  "available_count"
    t.integer  "status"
    t.text     "remark"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "last_encoding"
    t.integer  "used_count",      default: 0
    t.integer  "sub_company_id"
  end

  add_index "invoice_settings", ["available_count"], name: "index_invoice_settings_on_available_count", using: :btree
  add_index "invoice_settings", ["category", "code"], name: "index_invoice_settings_on_category_and_code", using: :btree
  add_index "invoice_settings", ["category", "status"], name: "index_invoice_settings_on_category_and_status", using: :btree
  add_index "invoice_settings", ["category"], name: "index_invoice_settings_on_category", using: :btree
  add_index "invoice_settings", ["code"], name: "index_invoice_settings_on_code", using: :btree
  add_index "invoice_settings", ["last_encoding"], name: "index_invoice_settings_on_last_encoding", using: :btree
  add_index "invoice_settings", ["remark"], name: "index_invoice_settings_on_remark", using: :btree
  add_index "invoice_settings", ["start_encoding"], name: "index_invoice_settings_on_start_encoding", using: :btree
  add_index "invoice_settings", ["status"], name: "index_invoice_settings_on_status", using: :btree
  add_index "invoice_settings", ["sub_company_id"], name: "index_invoice_settings_on_sub_company_id", using: :btree
  add_index "invoice_settings", ["used_count"], name: "index_invoice_settings_on_used_count", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.date     "date"
    t.text     "code"
    t.text     "encoding"
    t.integer  "category",                                default: 0
    t.integer  "scope",                                   default: 0
    t.text     "payer"
    t.decimal  "amount",         precision: 12, scale: 2
    t.decimal  "admin_amount",   precision: 12, scale: 2
    t.decimal  "total_amount",   precision: 12, scale: 2
    t.text     "contact"
    t.date     "income_date"
    t.date     "refund_date"
    t.text     "refund_person"
    t.text     "remark"
    t.integer  "status",                                  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_company_id"
    t.text     "management"
    t.integer  "project_id"
    t.string   "project_type"
  end

  add_index "invoices", ["admin_amount"], name: "index_invoices_on_admin_amount", using: :btree
  add_index "invoices", ["amount"], name: "index_invoices_on_amount", using: :btree
  add_index "invoices", ["category"], name: "index_invoices_on_category", using: :btree
  add_index "invoices", ["code"], name: "index_invoices_on_code", using: :btree
  add_index "invoices", ["contact"], name: "index_invoices_on_contact", using: :btree
  add_index "invoices", ["created_at"], name: "index_invoices_on_created_at", using: :btree
  add_index "invoices", ["date"], name: "index_invoices_on_date", using: :btree
  add_index "invoices", ["encoding"], name: "index_invoices_on_encoding", using: :btree
  add_index "invoices", ["income_date"], name: "index_invoices_on_income_date", using: :btree
  add_index "invoices", ["management"], name: "index_invoices_on_management", using: :btree
  add_index "invoices", ["payer"], name: "index_invoices_on_payer", using: :btree
  add_index "invoices", ["project_type", "project_id"], name: "index_invoices_on_project_type_and_project_id", using: :btree
  add_index "invoices", ["refund_date"], name: "index_invoices_on_refund_date", using: :btree
  add_index "invoices", ["refund_person"], name: "index_invoices_on_refund_person", using: :btree
  add_index "invoices", ["remark"], name: "index_invoices_on_remark", using: :btree
  add_index "invoices", ["scope"], name: "index_invoices_on_scope", using: :btree
  add_index "invoices", ["sub_company_id"], name: "index_invoices_on_sub_company_id", using: :btree
  add_index "invoices", ["total_amount"], name: "index_invoices_on_total_amount", using: :btree
  add_index "invoices", ["updated_at"], name: "index_invoices_on_updated_at", using: :btree

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
    t.decimal  "social_insurance_base",                precision: 12, scale: 2
    t.decimal  "medical_insurance_base",               precision: 12, scale: 2
    t.decimal  "house_accumulation_base",              precision: 12, scale: 2
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
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "nest_index"
  end

  add_index "labor_contracts", ["arrive_current_company_at"], name: "index_labor_contracts_on_arrive_current_company_at", using: :btree
  add_index "labor_contracts", ["backup_date"], name: "index_labor_contracts_on_backup_date", using: :btree
  add_index "labor_contracts", ["backup_place"], name: "index_labor_contracts_on_backup_place", using: :btree
  add_index "labor_contracts", ["contract_end_date"], name: "index_labor_contracts_on_contract_end_date", using: :btree
  add_index "labor_contracts", ["contract_start_date"], name: "index_labor_contracts_on_contract_start_date", using: :btree
  add_index "labor_contracts", ["contract_type"], name: "index_labor_contracts_on_contract_type", using: :btree
  add_index "labor_contracts", ["created_at", "in_contract"], name: "index_labor_contracts_on_created_at_and_in_contract", using: :btree
  add_index "labor_contracts", ["created_at"], name: "index_labor_contracts_on_created_at", using: :btree
  add_index "labor_contracts", ["current_medical_insurance_start_date"], name: "index_labor_contracts_on_current_medical_insurance_start_date", using: :btree
  add_index "labor_contracts", ["current_social_insurance_start_date"], name: "index_labor_contracts_on_current_social_insurance_start_date", using: :btree
  add_index "labor_contracts", ["has_accident_insurance"], name: "index_labor_contracts_on_has_accident_insurance", using: :btree
  add_index "labor_contracts", ["has_medical_insurance"], name: "index_labor_contracts_on_has_medical_insurance", using: :btree
  add_index "labor_contracts", ["has_social_insurance"], name: "index_labor_contracts_on_has_social_insurance", using: :btree
  add_index "labor_contracts", ["house_accumulation_base"], name: "index_labor_contracts_on_house_accumulation_base", using: :btree
  add_index "labor_contracts", ["in_contract"], name: "index_labor_contracts_on_in_contract", using: :btree
  add_index "labor_contracts", ["medical_insurance_base"], name: "index_labor_contracts_on_medical_insurance_base", using: :btree
  add_index "labor_contracts", ["medical_insurance_card"], name: "index_labor_contracts_on_medical_insurance_card", using: :btree
  add_index "labor_contracts", ["medical_insurance_release_date"], name: "index_labor_contracts_on_medical_insurance_release_date", using: :btree
  add_index "labor_contracts", ["medical_insurance_serial"], name: "index_labor_contracts_on_medical_insurance_serial", using: :btree
  add_index "labor_contracts", ["nest_index"], name: "index_labor_contracts_on_nest_index", using: :btree
  add_index "labor_contracts", ["normal_corporation_id"], name: "index_labor_contracts_on_normal_corporation_id", using: :btree
  add_index "labor_contracts", ["normal_staff_id"], name: "index_labor_contracts_on_normal_staff_id", using: :btree
  add_index "labor_contracts", ["release_date"], name: "index_labor_contracts_on_release_date", using: :btree
  add_index "labor_contracts", ["social_insurance_base"], name: "index_labor_contracts_on_social_insurance_base", using: :btree
  add_index "labor_contracts", ["social_insurance_release_date"], name: "index_labor_contracts_on_social_insurance_release_date", using: :btree
  add_index "labor_contracts", ["social_insurance_serial"], name: "index_labor_contracts_on_social_insurance_serial", using: :btree
  add_index "labor_contracts", ["updated_at", "in_contract"], name: "index_labor_contracts_on_updated_at_and_in_contract", using: :btree
  add_index "labor_contracts", ["updated_at"], name: "index_labor_contracts_on_updated_at", using: :btree
  add_index "labor_contracts", ["work_place"], name: "index_labor_contracts_on_work_place", using: :btree
  add_index "labor_contracts", ["work_type"], name: "index_labor_contracts_on_work_type", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "non_full_day_salary_items", force: :cascade do |t|
    t.decimal  "work_hour",                    precision: 12, scale: 2
    t.decimal  "work_wage",                    precision: 12, scale: 2
    t.decimal  "salary_deserve",               precision: 12, scale: 2
    t.decimal  "tax",                          precision: 12, scale: 2
    t.decimal  "other",                        precision: 12, scale: 2
    t.decimal  "salary_in_fact",               precision: 12, scale: 2
    t.decimal  "accident_insurance",           precision: 12, scale: 2
    t.decimal  "admin_amount",                 precision: 12, scale: 2
    t.integer  "normal_staff_id"
    t.text     "remark"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "non_full_day_salary_table_id"
    t.integer  "nest_index"
    t.text     "department"
    t.text     "station"
    t.decimal  "work_insurance",               precision: 12, scale: 2
    t.decimal  "other_amount",                 precision: 12, scale: 2
    t.integer  "role",                                                  default: 0
    t.text     "staff_name"
    t.text     "staff_account"
    t.decimal  "total_sum",                    precision: 12, scale: 2
    t.decimal  "total_sum_with_admin_amount",  precision: 12, scale: 2
  end

  add_index "non_full_day_salary_items", ["accident_insurance"], name: "index_non_full_day_salary_items_on_accident_insurance", using: :btree
  add_index "non_full_day_salary_items", ["admin_amount"], name: "index_non_full_day_salary_items_on_admin_amount", using: :btree
  add_index "non_full_day_salary_items", ["created_at"], name: "index_non_full_day_salary_items_on_created_at", using: :btree
  add_index "non_full_day_salary_items", ["department"], name: "index_non_full_day_salary_items_on_department", using: :btree
  add_index "non_full_day_salary_items", ["nest_index", "role"], name: "index_non_full_day_salary_items_on_nest_index_and_role", using: :btree
  add_index "non_full_day_salary_items", ["nest_index"], name: "index_non_full_day_salary_items_on_nest_index", using: :btree
  add_index "non_full_day_salary_items", ["non_full_day_salary_table_id"], name: "index_non_full_day_salary_items_on_non_full_day_salary_table_id", using: :btree
  add_index "non_full_day_salary_items", ["normal_staff_id"], name: "index_non_full_day_salary_items_on_normal_staff_id", using: :btree
  add_index "non_full_day_salary_items", ["other"], name: "index_non_full_day_salary_items_on_other", using: :btree
  add_index "non_full_day_salary_items", ["other_amount"], name: "index_non_full_day_salary_items_on_other_amount", using: :btree
  add_index "non_full_day_salary_items", ["remark"], name: "index_non_full_day_salary_items_on_remark", using: :btree
  add_index "non_full_day_salary_items", ["role"], name: "index_non_full_day_salary_items_on_role", using: :btree
  add_index "non_full_day_salary_items", ["salary_deserve"], name: "index_non_full_day_salary_items_on_salary_deserve", using: :btree
  add_index "non_full_day_salary_items", ["salary_in_fact"], name: "index_non_full_day_salary_items_on_salary_in_fact", using: :btree
  add_index "non_full_day_salary_items", ["staff_account"], name: "index_non_full_day_salary_items_on_staff_account", using: :btree
  add_index "non_full_day_salary_items", ["staff_name"], name: "index_non_full_day_salary_items_on_staff_name", using: :btree
  add_index "non_full_day_salary_items", ["station"], name: "index_non_full_day_salary_items_on_station", using: :btree
  add_index "non_full_day_salary_items", ["tax"], name: "index_non_full_day_salary_items_on_tax", using: :btree
  add_index "non_full_day_salary_items", ["total_sum"], name: "index_non_full_day_salary_items_on_total_sum", using: :btree
  add_index "non_full_day_salary_items", ["total_sum_with_admin_amount"], name: "index_non_full_day_salary_items_on_total_sum_with_admin_amount", using: :btree
  add_index "non_full_day_salary_items", ["updated_at"], name: "index_non_full_day_salary_items_on_updated_at", using: :btree
  add_index "non_full_day_salary_items", ["work_hour"], name: "index_non_full_day_salary_items_on_work_hour", using: :btree
  add_index "non_full_day_salary_items", ["work_insurance"], name: "index_non_full_day_salary_items_on_work_insurance", using: :btree
  add_index "non_full_day_salary_items", ["work_wage"], name: "index_non_full_day_salary_items_on_work_wage", using: :btree

  create_table "non_full_day_salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.integer  "normal_corporation_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.date     "start_date"
    t.text     "lai_table"
    t.text     "daka_table"
    t.integer  "status"
    t.hstore   "audition",                                       default: {}
    t.decimal  "amount",                precision: 12, scale: 2
  end

  add_index "non_full_day_salary_tables", ["amount"], name: "index_non_full_day_salary_tables_on_amount", using: :btree
  add_index "non_full_day_salary_tables", ["created_at"], name: "index_non_full_day_salary_tables_on_created_at", using: :btree
  add_index "non_full_day_salary_tables", ["name"], name: "index_non_full_day_salary_tables_on_name", using: :btree
  add_index "non_full_day_salary_tables", ["normal_corporation_id"], name: "index_non_full_day_salary_tables_on_normal_corporation_id", using: :btree
  add_index "non_full_day_salary_tables", ["remark"], name: "index_non_full_day_salary_tables_on_remark", using: :btree
  add_index "non_full_day_salary_tables", ["start_date"], name: "index_non_full_day_salary_tables_on_start_date", using: :btree
  add_index "non_full_day_salary_tables", ["status"], name: "index_non_full_day_salary_tables_on_status", using: :btree
  add_index "non_full_day_salary_tables", ["updated_at"], name: "index_non_full_day_salary_tables_on_updated_at", using: :btree

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
    t.money    "contract_amount",                    scale: 2
    t.integer  "admin_charge_type",                            default: 0
    t.decimal  "admin_charge_amount", precision: 12, scale: 2, default: 0.0
    t.date     "expense_date"
    t.text     "remark"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.date     "contract_start_date"
    t.date     "contract_end_date"
    t.text     "full_name"
    t.integer  "sub_company_id"
    t.integer  "status",                                       default: 0
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
  add_index "normal_corporations", ["status", "updated_at"], name: "index_normal_corporations_on_status_and_updated_at", using: :btree
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
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "normal_corporation_id"
    t.integer  "nest_index"
    t.boolean  "in_contract",                 default: false
    t.integer  "sub_company_id"
  end

  add_index "normal_staffs", ["account"], name: "index_normal_staffs_on_account", using: :btree
  add_index "normal_staffs", ["account_bank"], name: "index_normal_staffs_on_account_bank", using: :btree
  add_index "normal_staffs", ["address"], name: "index_normal_staffs_on_address", using: :btree
  add_index "normal_staffs", ["age"], name: "index_normal_staffs_on_age", using: :btree
  add_index "normal_staffs", ["birth"], name: "index_normal_staffs_on_birth", using: :btree
  add_index "normal_staffs", ["created_at", "in_contract"], name: "index_normal_staffs_on_created_at_and_in_contract", using: :btree
  add_index "normal_staffs", ["created_at"], name: "index_normal_staffs_on_created_at", using: :btree
  add_index "normal_staffs", ["gender"], name: "index_normal_staffs_on_gender", using: :btree
  add_index "normal_staffs", ["grade"], name: "index_normal_staffs_on_grade", using: :btree
  add_index "normal_staffs", ["identity_card"], name: "index_normal_staffs_on_identity_card", using: :btree
  add_index "normal_staffs", ["in_contract"], name: "index_normal_staffs_on_in_contract", using: :btree
  add_index "normal_staffs", ["in_service", "in_contract"], name: "index_normal_staffs_on_in_service_and_in_contract", using: :btree
  add_index "normal_staffs", ["in_service"], name: "index_normal_staffs_on_in_service", using: :btree
  add_index "normal_staffs", ["name"], name: "index_normal_staffs_on_name", using: :btree
  add_index "normal_staffs", ["nation"], name: "index_normal_staffs_on_nation", using: :btree
  add_index "normal_staffs", ["nest_index"], name: "index_normal_staffs_on_nest_index", using: :btree
  add_index "normal_staffs", ["normal_corporation_id"], name: "index_normal_staffs_on_normal_corporation_id", using: :btree
  add_index "normal_staffs", ["remark"], name: "index_normal_staffs_on_remark", using: :btree
  add_index "normal_staffs", ["social_insurance_start_date"], name: "index_normal_staffs_on_social_insurance_start_date", using: :btree
  add_index "normal_staffs", ["sub_company_id"], name: "index_normal_staffs_on_sub_company_id", using: :btree
  add_index "normal_staffs", ["telephone"], name: "index_normal_staffs_on_telephone", using: :btree
  add_index "normal_staffs", ["updated_at", "in_contract"], name: "index_normal_staffs_on_updated_at_and_in_contract", using: :btree
  add_index "normal_staffs", ["updated_at"], name: "index_normal_staffs_on_updated_at", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "salary_items", force: :cascade do |t|
    t.decimal  "salary_deserve",               precision: 12, scale: 2
    t.decimal  "annual_reward",                precision: 12, scale: 2
    t.decimal  "pension_personal",             precision: 12, scale: 2
    t.decimal  "pension_margin_personal",      precision: 12, scale: 2
    t.decimal  "unemployment_personal",        precision: 12, scale: 2
    t.decimal  "unemployment_margin_personal", precision: 12, scale: 2
    t.decimal  "medical_personal",             precision: 12, scale: 2
    t.decimal  "medical_margin_personal",      precision: 12, scale: 2
    t.decimal  "house_accumulation_personal",  precision: 12, scale: 2
    t.decimal  "big_amount_personal",          precision: 12, scale: 2
    t.decimal  "income_tax",                   precision: 12, scale: 2
    t.decimal  "salary_card_addition",         precision: 12, scale: 2
    t.decimal  "medical_scan_addition",        precision: 12, scale: 2
    t.decimal  "physical_exam_addition",       precision: 12, scale: 2
    t.decimal  "total_personal",               precision: 12, scale: 2
    t.decimal  "salary_in_fact",               precision: 12, scale: 2
    t.decimal  "pension_company",              precision: 12, scale: 2
    t.decimal  "pension_margin_company",       precision: 12, scale: 2
    t.decimal  "unemployment_company",         precision: 12, scale: 2
    t.decimal  "unemployment_margin_company",  precision: 12, scale: 2
    t.decimal  "medical_company",              precision: 12, scale: 2
    t.decimal  "medical_margin_company",       precision: 12, scale: 2
    t.decimal  "injury_company",               precision: 12, scale: 2
    t.decimal  "injury_margin_company",        precision: 12, scale: 2
    t.decimal  "birth_company",                precision: 12, scale: 2
    t.decimal  "birth_margin_company",         precision: 12, scale: 2
    t.decimal  "accident_company",             precision: 12, scale: 2
    t.decimal  "house_accumulation_company",   precision: 12, scale: 2
    t.decimal  "total_company",                precision: 12, scale: 2
    t.decimal  "admin_amount",                 precision: 12, scale: 2
    t.decimal  "total_sum",                    precision: 12, scale: 2
    t.decimal  "total_sum_with_admin_amount",  precision: 12, scale: 2
    t.text     "remark"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "salary_table_id"
    t.integer  "normal_staff_id"
    t.decimal  "deduct_addition",              precision: 12, scale: 2
    t.decimal  "salary_deduct_addition",       precision: 12, scale: 2
    t.decimal  "other_deduct_addition",        precision: 12, scale: 2
    t.decimal  "other_personal",               precision: 12, scale: 2
    t.decimal  "other_company",                precision: 12, scale: 2
    t.integer  "role",                                                  default: 0
    t.text     "staff_name"
    t.text     "staff_account"
    t.integer  "nest_index"
    t.decimal  "other_amount",                 precision: 12, scale: 2
  end

  add_index "salary_items", ["accident_company"], name: "index_salary_items_on_accident_company", using: :btree
  add_index "salary_items", ["admin_amount"], name: "index_salary_items_on_admin_amount", using: :btree
  add_index "salary_items", ["annual_reward"], name: "index_salary_items_on_annual_reward", using: :btree
  add_index "salary_items", ["big_amount_personal"], name: "index_salary_items_on_big_amount_personal", using: :btree
  add_index "salary_items", ["birth_company"], name: "index_salary_items_on_birth_company", using: :btree
  add_index "salary_items", ["birth_margin_company"], name: "index_salary_items_on_birth_margin_company", using: :btree
  add_index "salary_items", ["created_at"], name: "index_salary_items_on_created_at", using: :btree
  add_index "salary_items", ["deduct_addition"], name: "index_salary_items_on_deduct_addition", using: :btree
  add_index "salary_items", ["house_accumulation_company"], name: "index_salary_items_on_house_accumulation_company", using: :btree
  add_index "salary_items", ["house_accumulation_personal"], name: "index_salary_items_on_house_accumulation_personal", using: :btree
  add_index "salary_items", ["income_tax"], name: "index_salary_items_on_income_tax", using: :btree
  add_index "salary_items", ["injury_company"], name: "index_salary_items_on_injury_company", using: :btree
  add_index "salary_items", ["injury_margin_company"], name: "index_salary_items_on_injury_margin_company", using: :btree
  add_index "salary_items", ["medical_company"], name: "index_salary_items_on_medical_company", using: :btree
  add_index "salary_items", ["medical_margin_company"], name: "index_salary_items_on_medical_margin_company", using: :btree
  add_index "salary_items", ["medical_margin_personal"], name: "index_salary_items_on_medical_margin_personal", using: :btree
  add_index "salary_items", ["medical_personal"], name: "index_salary_items_on_medical_personal", using: :btree
  add_index "salary_items", ["medical_scan_addition"], name: "index_salary_items_on_medical_scan_addition", using: :btree
  add_index "salary_items", ["nest_index"], name: "index_salary_items_on_nest_index", using: :btree
  add_index "salary_items", ["normal_staff_id"], name: "index_salary_items_on_normal_staff_id", using: :btree
  add_index "salary_items", ["other_amount"], name: "index_salary_items_on_other_amount", using: :btree
  add_index "salary_items", ["other_company"], name: "index_salary_items_on_other_company", using: :btree
  add_index "salary_items", ["other_deduct_addition"], name: "index_salary_items_on_other_deduct_addition", using: :btree
  add_index "salary_items", ["other_personal"], name: "index_salary_items_on_other_personal", using: :btree
  add_index "salary_items", ["pension_company"], name: "index_salary_items_on_pension_company", using: :btree
  add_index "salary_items", ["pension_margin_company"], name: "index_salary_items_on_pension_margin_company", using: :btree
  add_index "salary_items", ["pension_margin_personal"], name: "index_salary_items_on_pension_margin_personal", using: :btree
  add_index "salary_items", ["pension_personal"], name: "index_salary_items_on_pension_personal", using: :btree
  add_index "salary_items", ["physical_exam_addition"], name: "index_salary_items_on_physical_exam_addition", using: :btree
  add_index "salary_items", ["remark"], name: "index_salary_items_on_remark", using: :btree
  add_index "salary_items", ["role"], name: "index_salary_items_on_role", using: :btree
  add_index "salary_items", ["salary_card_addition"], name: "index_salary_items_on_salary_card_addition", using: :btree
  add_index "salary_items", ["salary_deduct_addition"], name: "index_salary_items_on_salary_deduct_addition", using: :btree
  add_index "salary_items", ["salary_deserve"], name: "index_salary_items_on_salary_deserve", using: :btree
  add_index "salary_items", ["salary_in_fact"], name: "index_salary_items_on_salary_in_fact", using: :btree
  add_index "salary_items", ["salary_table_id", "accident_company"], name: "idx_on_st_and_accident_company", using: :btree
  add_index "salary_items", ["salary_table_id", "admin_amount"], name: "idx_on_st_and_admin_amount", using: :btree
  add_index "salary_items", ["salary_table_id", "annual_reward"], name: "idx_on_st_and_annual_reward", using: :btree
  add_index "salary_items", ["salary_table_id", "big_amount_personal"], name: "idx_on_st_and_big_amount_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "birth_company"], name: "idx_on_st_and_birth_company", using: :btree
  add_index "salary_items", ["salary_table_id", "birth_margin_company"], name: "idx_on_st_and_birth_margin_company", using: :btree
  add_index "salary_items", ["salary_table_id", "created_at"], name: "idx_on_st_and_created_at", using: :btree
  add_index "salary_items", ["salary_table_id", "deduct_addition"], name: "idx_on_st_and_deduct_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "house_accumulation_company"], name: "idx_on_st_and_house_accumulation_company", using: :btree
  add_index "salary_items", ["salary_table_id", "house_accumulation_personal"], name: "idx_on_st_and_house_accumulation_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "income_tax"], name: "idx_on_st_and_income_tax", using: :btree
  add_index "salary_items", ["salary_table_id", "injury_company"], name: "idx_on_st_and_injury_company", using: :btree
  add_index "salary_items", ["salary_table_id", "injury_margin_company"], name: "idx_on_st_and_injury_margin_company", using: :btree
  add_index "salary_items", ["salary_table_id", "medical_company"], name: "idx_on_st_and_medical_company", using: :btree
  add_index "salary_items", ["salary_table_id", "medical_margin_company"], name: "idx_on_st_and_medical_margin_company", using: :btree
  add_index "salary_items", ["salary_table_id", "medical_margin_personal"], name: "idx_on_st_and_medical_margin_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "medical_personal"], name: "idx_on_st_and_medical_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "medical_scan_addition"], name: "idx_on_st_and_medical_scan_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "nest_index", "role"], name: "index_salary_items_on_salary_table_id_and_nest_index_and_role", using: :btree
  add_index "salary_items", ["salary_table_id", "nest_index"], name: "index_salary_items_on_salary_table_id_and_nest_index", using: :btree
  add_index "salary_items", ["salary_table_id", "normal_staff_id"], name: "idx_on_st_and_normal_staff_id", using: :btree
  add_index "salary_items", ["salary_table_id", "other_company"], name: "idx_on_st_and_other_company", using: :btree
  add_index "salary_items", ["salary_table_id", "other_deduct_addition"], name: "idx_on_st_and_other_deduct_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "other_personal"], name: "idx_on_st_and_other_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "pension_company"], name: "idx_on_st_and_pension_company", using: :btree
  add_index "salary_items", ["salary_table_id", "pension_margin_company"], name: "idx_on_st_and_pension_margin_company", using: :btree
  add_index "salary_items", ["salary_table_id", "pension_margin_personal"], name: "idx_on_st_and_pension_margin_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "pension_personal"], name: "idx_on_st_and_pension_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "physical_exam_addition"], name: "idx_on_st_and_physical_exam_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "remark"], name: "idx_on_st_and_remark", using: :btree
  add_index "salary_items", ["salary_table_id", "role"], name: "idx_on_st_and_role", using: :btree
  add_index "salary_items", ["salary_table_id", "salary_card_addition"], name: "idx_on_st_and_salary_card_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "salary_deduct_addition"], name: "idx_on_st_and_salary_deduct_addition", using: :btree
  add_index "salary_items", ["salary_table_id", "salary_deserve"], name: "idx_on_st_and_salary_deserve", using: :btree
  add_index "salary_items", ["salary_table_id", "salary_in_fact"], name: "idx_on_st_and_salary_in_fact", using: :btree
  add_index "salary_items", ["salary_table_id", "total_company"], name: "idx_on_st_and_total_company", using: :btree
  add_index "salary_items", ["salary_table_id", "total_personal"], name: "idx_on_st_and_total_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "total_sum"], name: "idx_on_st_and_total_sum", using: :btree
  add_index "salary_items", ["salary_table_id", "total_sum_with_admin_amount"], name: "idx_on_st_and_total_sum_with_admin_amount", using: :btree
  add_index "salary_items", ["salary_table_id", "unemployment_company"], name: "idx_on_st_and_unemployment_company", using: :btree
  add_index "salary_items", ["salary_table_id", "unemployment_margin_company"], name: "idx_on_st_and_unemployment_margin_company", using: :btree
  add_index "salary_items", ["salary_table_id", "unemployment_margin_personal"], name: "idx_on_st_and_unemployment_margin_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "unemployment_personal"], name: "idx_on_st_and_unemployment_personal", using: :btree
  add_index "salary_items", ["salary_table_id", "updated_at"], name: "idx_on_st_and_updated_at", using: :btree
  add_index "salary_items", ["salary_table_id"], name: "index_salary_items_on_salary_table_id", using: :btree
  add_index "salary_items", ["staff_account"], name: "index_salary_items_on_staff_account", using: :btree
  add_index "salary_items", ["staff_name"], name: "index_salary_items_on_staff_name", using: :btree
  add_index "salary_items", ["total_company"], name: "index_salary_items_on_total_company", using: :btree
  add_index "salary_items", ["total_personal"], name: "index_salary_items_on_total_personal", using: :btree
  add_index "salary_items", ["total_sum"], name: "index_salary_items_on_total_sum", using: :btree
  add_index "salary_items", ["total_sum_with_admin_amount"], name: "index_salary_items_on_total_sum_with_admin_amount", using: :btree
  add_index "salary_items", ["unemployment_company"], name: "index_salary_items_on_unemployment_company", using: :btree
  add_index "salary_items", ["unemployment_margin_company"], name: "index_salary_items_on_unemployment_margin_company", using: :btree
  add_index "salary_items", ["unemployment_margin_personal"], name: "index_salary_items_on_unemployment_margin_personal", using: :btree
  add_index "salary_items", ["unemployment_personal"], name: "index_salary_items_on_unemployment_personal", using: :btree
  add_index "salary_items", ["updated_at"], name: "index_salary_items_on_updated_at", using: :btree

  create_table "salary_tables", force: :cascade do |t|
    t.text     "name"
    t.text     "remark"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "normal_corporation_id"
    t.text     "lai_table"
    t.text     "daka_table"
    t.date     "start_date"
    t.integer  "status",                                        default: 0
    t.hstore   "audition",                                      default: {}
    t.decimal  "amount",                precision: 8, scale: 2
  end

  add_index "salary_tables", ["amount"], name: "index_salary_tables_on_amount", using: :btree
  add_index "salary_tables", ["created_at"], name: "index_salary_tables_on_created_at", using: :btree
  add_index "salary_tables", ["name"], name: "index_salary_tables_on_name", using: :btree
  add_index "salary_tables", ["normal_corporation_id"], name: "index_salary_tables_on_normal_corporation_id", using: :btree
  add_index "salary_tables", ["start_date"], name: "index_salary_tables_on_start_date", using: :btree
  add_index "salary_tables", ["status"], name: "index_salary_tables_on_status", using: :btree
  add_index "salary_tables", ["updated_at"], name: "index_salary_tables_on_updated_at", using: :btree

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
  add_foreign_key "guard_salary_tables", "normal_corporations"
  add_foreign_key "invoice_settings", "sub_companies"
  add_foreign_key "invoices", "sub_companies"
  add_foreign_key "labor_contracts", "normal_corporations"
  add_foreign_key "labor_contracts", "normal_staffs"
  add_foreign_key "non_full_day_salary_items", "non_full_day_salary_tables"
  add_foreign_key "non_full_day_salary_items", "normal_staffs"
  add_foreign_key "non_full_day_salary_tables", "normal_corporations"
  add_foreign_key "normal_corporations", "sub_companies"
  add_foreign_key "normal_staffs", "normal_corporations"
  add_foreign_key "salary_items", "normal_staffs"
  add_foreign_key "salary_items", "salary_tables"
  add_foreign_key "salary_tables", "normal_corporations"
  add_foreign_key "seal_items", "seal_tables"
end
