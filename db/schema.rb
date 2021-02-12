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

ActiveRecord::Schema.define(version: 20161121044203) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "bank_accounts", force: :cascade do |t|
    t.integer  "profile_id",                                      null: false
    t.string   "document_type",  limit: 20,                       null: false
    t.string   "document_id",    limit: 50,                       null: false
    t.string   "owner_name",     limit: 50,                       null: false
    t.string   "bank_name",      limit: 50,                       null: false
    t.string   "account_type",   limit: 20,                       null: false
    t.string   "account_number", limit: 60,                       null: false
    t.string   "country",        limit: 20, default: "venezuela", null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "bank_accounts", ["profile_id"], name: "index_bank_accounts_on_profile_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "conversation_id"
    t.string   "uuid",            null: false
    t.string   "user_id",         null: false
    t.text     "data",            null: false
    t.string   "user_pic"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "comments", ["conversation_id"], name: "index_comments_on_conversation_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "conversations", ["commentable_id", "commentable_type"], name: "index_conversations_on_commentable_id_and_commentable_type", unique: true, using: :btree

  create_table "facebook_accounts", force: :cascade do |t|
    t.string   "user_id"
    t.string   "token"
    t.integer  "expires_in"
    t.string   "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "facebook_accounts", ["user_id"], name: "index_facebook_accounts_on_user_id", using: :btree
  add_index "facebook_accounts", ["uuid"], name: "index_facebook_accounts_on_uuid", unique: true, using: :btree

  create_table "fulfillments", force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "order_id",   null: false
    t.string   "status",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fulfillments", ["order_id"], name: "index_fulfillments_on_order_id", using: :btree

  create_table "ionic_webhook_callbacks", force: :cascade do |t|
    t.text     "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.string   "uuid",         null: false
    t.string   "order_id",     null: false
    t.string   "product_type", null: false
    t.string   "product_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mp_customers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "user_id",    null: false
    t.jsonb    "payload",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mp_customers", ["user_id"], name: "index_mp_customers_on_user_id", unique: true, using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "uuid",                   null: false
    t.string   "payment_transaction_id", null: false
    t.float    "total_amount",           null: false
    t.string   "user_id",                null: false
    t.string   "financial_status",       null: false
    t.string   "currency",               null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "orders", ["user_id", "uuid"], name: "index_orders_on_user_id_and_uuid", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payment_audit_trails", force: :cascade do |t|
    t.string   "uuid",                   null: false
    t.string   "user_id",                null: false
    t.string   "payment_transaction_id", null: false
    t.string   "action",                 null: false
    t.text     "metadata"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "payment_audit_trails", ["user_id"], name: "index_payment_audit_trails_on_user_id", using: :btree

  create_table "payment_transactions", force: :cascade do |t|
    t.string   "uuid",                        null: false
    t.string   "user_id",                     null: false
    t.string   "status"
    t.text     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_method",   limit: 20
    t.string   "payment_provider", limit: 60
  end

  create_table "payouts", force: :cascade do |t|
    t.string   "user_id"
    t.string   "uuid"
    t.float    "amount",                null: false
    t.string   "status",     limit: 40, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "payouts", ["user_id"], name: "index_payouts_on_user_id", using: :btree

  create_table "product_pictures", force: :cascade do |t|
    t.string   "user_id"
    t.string   "product_id"
    t.integer  "position"
    t.datetime "created_at",       precision: 3, null: false
    t.datetime "updated_at",       precision: 3, null: false
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
  end

  add_index "product_pictures", ["product_id"], name: "index_product_pictures_on_product_id", using: :btree
  add_index "product_pictures", ["user_id"], name: "index_product_pictures_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "uuid"
    t.string   "title"
    t.text     "description"
    t.string   "category"
    t.string   "user_id",                                             null: false
    t.float    "price"
    t.float    "original_price"
    t.string   "currency"
    t.string   "status"
    t.string   "location"
    t.string   "lat_lon"
    t.datetime "created_at",              precision: 3,               null: false
    t.datetime "updated_at",              precision: 3,               null: false
    t.boolean  "featured"
    t.integer  "cached_votes_total",                    default: 0
    t.integer  "cached_votes_score",                    default: 0
    t.integer  "cached_votes_up",                       default: 0
    t.integer  "cached_votes_down",                     default: 0
    t.integer  "cached_weighted_score",                 default: 0
    t.integer  "cached_weighted_total",                 default: 0
    t.float    "cached_weighted_average",               default: 0.0
    t.string   "size"
  end

  add_index "products", ["cached_votes_down"], name: "index_products_on_cached_votes_down", using: :btree
  add_index "products", ["cached_votes_score"], name: "index_products_on_cached_votes_score", using: :btree
  add_index "products", ["cached_votes_total"], name: "index_products_on_cached_votes_total", using: :btree
  add_index "products", ["cached_votes_up"], name: "index_products_on_cached_votes_up", using: :btree
  add_index "products", ["cached_weighted_average"], name: "index_products_on_cached_weighted_average", using: :btree
  add_index "products", ["cached_weighted_score"], name: "index_products_on_cached_weighted_score", using: :btree
  add_index "products", ["cached_weighted_total"], name: "index_products_on_cached_weighted_total", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",       precision: 3,               null: false
    t.datetime "updated_at",       precision: 3,               null: false
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
    t.text     "bio"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "website"
    t.float    "store_fee",                      default: 0.0
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "push_tokens", force: :cascade do |t|
    t.string   "user_id",     limit: 160, null: false
    t.string   "uuid",        limit: 160, null: false
    t.string   "platform",    limit: 30,  null: false
    t.string   "token",       limit: 160, null: false
    t.string   "device_id",   limit: 160
    t.string   "environment", limit: 30,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "push_tokens", ["token", "platform"], name: "index_push_tokens_on_token_and_platform", unique: true, using: :btree
  add_index "push_tokens", ["user_id", "platform"], name: "index_push_tokens_on_user_id_and_platform", using: :btree
  add_index "push_tokens", ["user_id"], name: "index_push_tokens_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "follower_id", null: false
    t.string   "followed_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "sales", force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "user_id",    null: false
    t.string   "order_id",   null: false
    t.float    "amount",     null: false
    t.float    "store_fee",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sales", ["user_id", "uuid"], name: "index_sales_on_user_id_and_uuid", using: :btree
  add_index "sales", ["user_id"], name: "index_sales_on_user_id", using: :btree

  create_table "timeline_cards", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "title",      null: false
    t.string   "card_type",  null: false
    t.jsonb    "payload",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "user_id"
    t.string   "checksum"
  end

  add_index "timeline_cards", ["card_type"], name: "index_timeline_cards_on_card_type", using: :btree
  add_index "timeline_cards", ["checksum"], name: "index_timeline_cards_on_checksum", unique: true, using: :btree
  add_index "timeline_cards", ["user_id"], name: "index_timeline_cards_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                                                     null: false
    t.string   "uuid",                                                         null: false
    t.string   "email",                                                        null: false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.integer  "login_count",                                      default: 0, null: false
    t.integer  "failed_login_count",                               default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                         precision: 3,             null: false
    t.datetime "updated_at",                         precision: 3,             null: false
    t.string   "password_reset_token",   limit: 128
    t.datetime "password_reset_sent_at"
    t.string   "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "bank_accounts", "profiles"
  add_foreign_key "profiles", "users"
end
