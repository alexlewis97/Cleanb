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

ActiveRecord::Schema.define(version: 2019_11_04_204141) do

  create_table "employees", force: :cascade do |t|
    t.string "type_of_work"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "flats", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "slots"
    t.integer "cluster"
    t.string "temp_cluster"
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "check_in"
    t.datetime "check_out"
    t.integer "flat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "flat_id"
    t.string "type_of_task"
    t.string "status"
  end

  create_table "work_days", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_tasks", force: :cascade do |t|
    t.integer "work_day_id"
    t.integer "task_id"
    t.boolean "finished"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
  end

end
