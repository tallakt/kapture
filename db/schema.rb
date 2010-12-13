# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100606073615) do

  create_table "camera_allowed_options", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "camera_option_id"
  end

  create_table "camera_options", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "opt_type"
  end

  create_table "capture_derivatives", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.integer  "capture_id"
  end

  create_table "captures", :force => true do |t|
    t.string   "camera_file"
    t.string   "thumbnail"
    t.string   "fullsize"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preview_w"
    t.integer  "preview_h"
    t.text     "histogram"
  end

  create_table "servo_options", :force => true do |t|
    t.float    "rotation_neutral"
    t.float    "rotation_rpm"
    t.float    "tilt_horizontal"
    t.float    "tilt_vertical"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rotation_pin"
    t.integer  "tilt_pin"
  end

  create_table "worker_feedbacks", :force => true do |t|
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gphoto_version"
    t.string   "model_name"
  end

  create_table "worker_tasks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "task"
  end

end
