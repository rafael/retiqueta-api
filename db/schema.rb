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

ActiveRecord::Schema.define(version: 20160215010959) do

  create_table "comments", force: :cascade do |t|
    t.integer  "conversation_id", limit: 4
    t.string   "uuid",            limit: 255,   null: false
    t.string   "user_id",         limit: 255,   null: false
    t.text     "data",            limit: 65535, null: false
    t.string   "user_pic",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "comments", ["conversation_id"], name: "index_comments_on_conversation_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "conversations", ["commentable_id", "commentable_type"], name: "index_conversations_on_commentable_id_and_commentable_type", unique: true, using: :btree

  create_table "ionic_webhook_callbacks", force: :cascade do |t|
    t.text     "payload",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string   "uuid",                   limit: 255, null: false
    t.string   "payment_method_id",      limit: 255, null: false
    t.string   "shipping_address",       limit: 255, null: false
    t.string   "payment_transaction_id", limit: 255, null: false
    t.string   "total_price",            limit: 255, null: false
    t.string   "float",                  limit: 255, null: false
    t.string   "user_id",                limit: 255, null: false
    t.string   "financial_status",       limit: 255, null: false
    t.string   "currency",               limit: 255, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "product_pictures", force: :cascade do |t|
    t.string   "user_id",          limit: 255
    t.string   "product_id",       limit: 255
    t.integer  "position",         limit: 4
    t.datetime "created_at",                   precision: 3, null: false
    t.datetime "updated_at",                   precision: 3, null: false
    t.string   "pic_file_name",    limit: 255
    t.string   "pic_content_type", limit: 255
    t.integer  "pic_file_size",    limit: 4
    t.datetime "pic_updated_at"
  end

  add_index "product_pictures", ["product_id"], name: "index_product_pictures_on_product_id", using: :btree
  add_index "product_pictures", ["user_id"], name: "index_product_pictures_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "uuid",                    limit: 255
    t.string   "title",                   limit: 255
    t.text     "description",             limit: 65535
    t.string   "category",                limit: 255
    t.string   "user_id",                 limit: 255,                               null: false
    t.float    "price",                   limit: 24
    t.float    "original_price",          limit: 24
    t.boolean  "featured"
    t.string   "currency",                limit: 255
    t.string   "status",                  limit: 255
    t.string   "location",                limit: 255
    t.string   "lat_lon",                 limit: 255
    t.datetime "created_at",                            precision: 3,               null: false
    t.datetime "updated_at",                            precision: 3,               null: false
    t.integer  "cached_votes_total",      limit: 4,                   default: 0
    t.integer  "cached_votes_score",      limit: 4,                   default: 0
    t.integer  "cached_votes_up",         limit: 4,                   default: 0
    t.integer  "cached_votes_down",       limit: 4,                   default: 0
    t.integer  "cached_weighted_score",   limit: 4,                   default: 0
    t.integer  "cached_weighted_total",   limit: 4,                   default: 0
    t.float    "cached_weighted_average", limit: 24,                  default: 0.0
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
    t.integer  "user_id",          limit: 4
    t.datetime "created_at",                     precision: 3, null: false
    t.datetime "updated_at",                     precision: 3, null: false
    t.string   "pic_file_name",    limit: 255
    t.string   "pic_content_type", limit: 255
    t.integer  "pic_file_size",    limit: 4
    t.datetime "pic_updated_at"
    t.text     "bio",              limit: 65535
    t.string   "country",          limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.string   "website",          limit: 255
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

  add_index "push_tokens", ["user_id", "platform"], name: "index_push_tokens_on_user_id_and_platform", using: :btree
  add_index "push_tokens", ["user_id"], name: "index_push_tokens_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "follower_id", limit: 255, null: false
    t.string   "followed_id", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",           limit: 255,                           null: false
    t.string   "uuid",               limit: 255,                           null: false
    t.string   "email",              limit: 255,                           null: false
    t.string   "crypted_password",   limit: 255
    t.string   "password_salt",      limit: 255
    t.string   "persistence_token",  limit: 255
    t.string   "perishable_token",   limit: 255
    t.integer  "login_count",        limit: 4,                 default: 0, null: false
    t.integer  "failed_login_count", limit: 4,                 default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",   limit: 255
    t.string   "last_login_ip",      limit: 255
    t.datetime "created_at",                     precision: 3,             null: false
    t.datetime "updated_at",                     precision: 3,             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id",   limit: 4
    t.string   "votable_type", limit: 255
    t.integer  "voter_id",     limit: 4
    t.string   "voter_type",   limit: 255
    t.boolean  "vote_flag"
    t.string   "vote_scope",   limit: 255
    t.integer  "vote_weight",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "profiles", "users"
end
