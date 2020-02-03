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

ActiveRecord::Schema.define(version: 2019_11_28_123138) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "additives", force: :cascade do |t|
    t.bigint "bidding_id"
    t.date "from"
    t.date "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bidding_id"], name: "index_additives_on_bidding_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.decimal "latitude", precision: 11, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "address"
    t.string "number"
    t.string "neighborhood"
    t.string "cep"
    t.string "complement"
    t.string "reference_point"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
    t.index ["city_id"], name: "index_addresses_on_city_id"
  end

  create_table "admins", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.integer "role", default: 2
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id"
  end

  create_table "biddings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "covenant_id"
    t.integer "kind"
    t.integer "status", default: 0
    t.integer "deadline"
    t.string "link"
    t.date "start_date"
    t.date "closing_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.integer "modality"
    t.date "draw_at"
    t.integer "draw_end_days", default: 0
    t.bigint "parent_id"
    t.bigint "edict_document_id"
    t.bigint "classification_id"
    t.string "code"
    t.integer "position"
    t.float "estimated_cost_total"
    t.bigint "merged_minute_document_id"
    t.string "proposal_import_file"
    t.bigint "reopen_reason_contract_id"
    t.index ["classification_id"], name: "index_biddings_on_classification_id"
    t.index ["covenant_id"], name: "index_biddings_on_covenant_id"
    t.index ["edict_document_id"], name: "index_biddings_on_edict_document_id"
    t.index ["merged_minute_document_id"], name: "index_biddings_on_merged_minute_document_id"
    t.index ["reopen_reason_contract_id"], name: "index_biddings_on_reopen_reason_contract_id"
  end

  create_table "biddings_and_minute_documents", id: false, force: :cascade do |t|
    t.bigint "bidding_id"
    t.bigint "minute_document_id"
    t.index ["bidding_id"], name: "index_biddings_and_minute_documents_on_bidding_id"
    t.index ["minute_document_id"], name: "index_biddings_and_minute_documents_on_minute_document_id"
  end

  create_table "cities", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.bigint "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "classifications", force: :cascade do |t|
    t.string "name"
    t.bigint "classification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code"
    t.index ["classification_id"], name: "index_classifications_on_classification_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "proposal_id"
    t.bigint "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "supplier_signed_at"
    t.datetime "user_signed_at"
    t.bigint "supplier_id"
    t.bigint "user_id"
    t.datetime "deleted_at"
    t.integer "refused_by_id"
    t.string "refused_by_type"
    t.datetime "refused_by_at"
    t.bigint "document_id"
    t.integer "deadline"
    t.string "title"
    t.index ["document_id"], name: "index_contracts_on_document_id"
    t.index ["proposal_id"], name: "index_contracts_on_proposal_id"
    t.index ["supplier_id"], name: "index_contracts_on_supplier_id"
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "cooperatives", force: :cascade do |t|
    t.text "name"
    t.string "cnpj"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "covenants", force: :cascade do |t|
    t.string "number"
    t.integer "status"
    t.date "signature_date"
    t.date "validity_date"
    t.bigint "cooperative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "admin_id"
    t.float "estimated_cost"
    t.bigint "city_id"
    t.index ["admin_id"], name: "index_covenants_on_admin_id"
    t.index ["city_id"], name: "index_covenants_on_city_id"
    t.index ["cooperative_id"], name: "index_covenants_on_cooperative_id"
  end

  create_table "device_tokens", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_device_tokens_on_owner_type_and_owner_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "eventable_type"
    t.bigint "eventable_id"
    t.string "creator_type"
    t.bigint "creator_id"
    t.jsonb "data", default: {}, null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_type", "creator_id"], name: "index_events_on_creator_type_and_creator_id"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
  end

  create_table "group_items", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "item_id"
    t.decimal "quantity", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "estimated_cost"
    t.decimal "available_quantity", precision: 10, scale: 2
    t.index ["group_id"], name: "index_group_items_on_group_id"
    t.index ["item_id"], name: "index_group_items_on_item_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "covenant_id"
    t.integer "group_items_count", default: 0
    t.index ["covenant_id"], name: "index_groups_on_covenant_id"
  end

  create_table "integration_configurations", force: :cascade do |t|
    t.string "type"
    t.string "endpoint_url"
    t.string "token"
    t.string "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.text "log"
    t.datetime "last_importation"
    t.datetime "last_success_at"
  end

  create_table "invites", force: :cascade do |t|
    t.integer "status", default: 0
    t.bigint "provider_id"
    t.bigint "bidding_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bidding_id"], name: "index_invites_on_bidding_id"
    t.index ["provider_id"], name: "index_invites_on_provider_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "classification_id"
    t.bigint "code"
    t.integer "unit_id"
    t.index ["classification_id"], name: "index_items_on_classification_id"
    t.index ["owner_type", "owner_id"], name: "index_items_on_owner_type_and_owner_id"
  end

  create_table "legal_representatives", force: :cascade do |t|
    t.string "representable_type"
    t.bigint "representable_id"
    t.string "name"
    t.string "nationality"
    t.integer "civil_state"
    t.string "rg"
    t.string "cpf"
    t.date "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["representable_type", "representable_id"], name: "index_legal_reps_on_representable_type_and_representable_id"
  end

  create_table "lot_group_item_lot_proposals", force: :cascade do |t|
    t.bigint "lot_group_item_id"
    t.bigint "lot_proposal_id"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_group_item_id"], name: "index_lot_group_item_lot_proposals_on_lot_group_item_id"
    t.index ["lot_proposal_id"], name: "index_lot_group_item_lot_proposals_on_lot_proposal_id"
  end

  create_table "lot_group_items", force: :cascade do |t|
    t.bigint "lot_id"
    t.bigint "group_item_id"
    t.decimal "quantity", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_item_id"], name: "index_lot_group_items_on_group_item_id"
    t.index ["lot_id"], name: "index_lot_group_items_on_lot_id"
  end

  create_table "lot_proposal_imports", force: :cascade do |t|
    t.bigint "provider_id"
    t.bigint "bidding_id"
    t.bigint "lot_id"
    t.string "file", null: false
    t.string "error_message"
    t.text "error_backtrace"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "file_type", default: 0
    t.index ["bidding_id"], name: "index_lot_proposal_imports_on_bidding_id"
    t.index ["lot_id"], name: "index_lot_proposal_imports_on_lot_id"
    t.index ["provider_id"], name: "index_lot_proposal_imports_on_provider_id"
  end

  create_table "lot_proposals", force: :cascade do |t|
    t.bigint "lot_id"
    t.decimal "price_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "proposal_id"
    t.bigint "supplier_id"
    t.decimal "delivery_price"
    t.bigint "parent_id"
    t.index ["lot_id", "supplier_id"], name: "index_lot_proposals_on_lot_id_and_supplier_id", unique: true
    t.index ["lot_id"], name: "index_lot_proposals_on_lot_id"
    t.index ["proposal_id"], name: "index_lot_proposals_on_proposal_id"
    t.index ["supplier_id"], name: "index_lot_proposals_on_supplier_id"
  end

  create_table "lots", force: :cascade do |t|
    t.bigint "bidding_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lot_group_items_count"
    t.integer "status", default: 0
    t.text "address"
    t.integer "deadline"
    t.integer "position"
    t.float "estimated_cost_total"
    t.string "lot_proposal_import_file"
    t.integer "lot_proposals_count"
    t.index ["bidding_id"], name: "index_lots_on_bidding_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "receivable_type"
    t.bigint "receivable_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.jsonb "data", default: {}, null: false
    t.datetime "read_at"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_notifications_on_action"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["receivable_type", "receivable_id"], name: "index_notifications_on_receivable_type_and_receivable_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_oauth_applications_on_name", unique: true
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "proposal_imports", force: :cascade do |t|
    t.bigint "provider_id"
    t.bigint "bidding_id"
    t.string "file", null: false
    t.string "error_message"
    t.text "error_backtrace"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "file_type", default: 0
    t.index ["bidding_id"], name: "index_proposal_imports_on_bidding_id"
    t.index ["provider_id"], name: "index_proposal_imports_on_provider_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.bigint "bidding_id"
    t.bigint "provider_id"
    t.integer "status"
    t.decimal "price_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sent_updated_at"
    t.index ["bidding_id"], name: "index_proposals_on_bidding_id"
    t.index ["provider_id"], name: "index_proposals_on_provider_id"
  end

  create_table "provider_classifications", force: :cascade do |t|
    t.bigint "provider_id"
    t.bigint "classification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string "document"
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "blocked", default: false, null: false
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "admin_id"
    t.integer "report_type", default: 0
    t.integer "status", default: 0
    t.string "url"
    t.string "error_message"
    t.text "error_backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_reports_on_admin_id"
  end

  create_table "returned_lot_group_items", force: :cascade do |t|
    t.decimal "quantity", precision: 10, scale: 2
    t.bigint "contract_id"
    t.bigint "lot_group_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "uf"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code"
  end

  create_table "suppliers", force: :cascade do |t|
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
    t.string "name", null: false
    t.string "phone", null: false
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_id"
    t.string "avatar"
    t.index ["email"], name: "index_suppliers_on_email", unique: true
    t.index ["provider_id"], name: "index_suppliers_on_provider_id"
    t.index ["reset_password_token"], name: "index_suppliers_on_reset_password_token", unique: true
  end

  create_table "systems", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.bigint "cooperative_id"
    t.string "phone"
    t.string "cpf"
    t.bigint "role_id"
    t.string "avatar"
    t.index ["cooperative_id"], name: "index_users_on_cooperative_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "ip"
    t.string "user_agent"
    t.string "class_name", null: false
    t.index ["class_name"], name: "index_versions_on_class_name"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["owner_type", "owner_id"], name: "index_versions_on_owner_type_and_owner_id"
  end

  add_foreign_key "additives", "biddings"
  add_foreign_key "addresses", "cities"
  add_foreign_key "biddings", "classifications"
  add_foreign_key "biddings", "contracts", column: "reopen_reason_contract_id"
  add_foreign_key "biddings", "covenants"
  add_foreign_key "biddings", "documents", column: "edict_document_id"
  add_foreign_key "biddings", "documents", column: "merged_minute_document_id"
  add_foreign_key "biddings_and_minute_documents", "biddings"
  add_foreign_key "biddings_and_minute_documents", "documents", column: "minute_document_id"
  add_foreign_key "cities", "states"
  add_foreign_key "classifications", "classifications"
  add_foreign_key "contracts", "documents"
  add_foreign_key "contracts", "proposals"
  add_foreign_key "contracts", "suppliers"
  add_foreign_key "contracts", "users"
  add_foreign_key "covenants", "admins"
  add_foreign_key "covenants", "cities"
  add_foreign_key "covenants", "cooperatives"
  add_foreign_key "group_items", "groups"
  add_foreign_key "group_items", "items"
  add_foreign_key "groups", "covenants"
  add_foreign_key "invites", "biddings"
  add_foreign_key "invites", "providers"
  add_foreign_key "items", "classifications"
  add_foreign_key "lot_group_item_lot_proposals", "lot_group_items"
  add_foreign_key "lot_group_item_lot_proposals", "lot_proposals"
  add_foreign_key "lot_group_items", "group_items"
  add_foreign_key "lot_group_items", "lots"
  add_foreign_key "lot_proposal_imports", "biddings"
  add_foreign_key "lot_proposal_imports", "lots"
  add_foreign_key "lot_proposal_imports", "providers"
  add_foreign_key "lot_proposals", "lots"
  add_foreign_key "lot_proposals", "suppliers"
  add_foreign_key "lots", "biddings"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "proposal_imports", "biddings"
  add_foreign_key "proposal_imports", "providers"
  add_foreign_key "proposals", "biddings"
  add_foreign_key "proposals", "providers"
  add_foreign_key "reports", "admins"
  add_foreign_key "suppliers", "providers"
  add_foreign_key "users", "cooperatives"
  add_foreign_key "users", "roles"
end
