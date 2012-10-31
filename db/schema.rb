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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121031213346) do

  create_table "customers", :force => true do |t|
    t.integer  "shopifystores_id"
    t.integer  "shopify_customer_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "country"
    t.string   "tags"
    t.string   "state"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "orders", :force => true do |t|
    t.integer  "shopify_order_id"
    t.string   "shopify_name"
    t.datetime "order_date"
    t.integer  "no_of_items"
    t.float    "price"
    t.string   "vendor_name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "shopify_owner"
    t.string   "paid_status"
    t.string   "shipped_status"
    t.float    "subtotal_price"
    t.float    "total_tax"
    t.datetime "cancelled_at"
    t.string   "gateway"
    t.string   "processing_method"
    t.boolean  "taxes_included"
    t.integer  "customer_id"
    t.float    "tax_line"
    t.integer  "shopifystores_id"
    t.integer  "product_id"
  end

  create_table "products", :force => true do |t|
    t.integer  "shopifystores_id"
    t.string   "title"
    t.integer  "shopify_product_id"
    t.string   "tags"
    t.string   "product_type"
    t.float    "price"
    t.string   "sku"
    t.integer  "inventory_qty"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "shopifystores", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "lastorderupdate"
    t.string   "currency"
    t.string   "taxesincluded"
    t.string   "shopifyplan"
    t.string   "shopify_owner"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
