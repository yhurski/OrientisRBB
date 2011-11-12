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

ActiveRecord::Schema.define(:version => 20111014123503) do

  create_table "admins", :force => true do |t|
    t.string   "name",       :limit => 30, :null => false
    t.string   "passwd",     :limit => 50, :null => false
    t.string   "email",      :limit => 30, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_visit",               :null => false
  end

  create_table "attach_files", :force => true do |t|
    t.integer  "user_id",             :null => false
    t.integer  "post_id",             :null => false
    t.integer  "topic_id",            :null => false
    t.string   "attach_file_name"
    t.integer  "attach_file_size"
    t.string   "attach_content_type"
    t.datetime "attach_updated_at"
    t.integer  "download_counter",    :null => false
  end

  create_table "bans", :force => true do |t|
    t.string   "username",    :limit => 25
    t.string   "ip",                        :default => "0.0.0.0", :null => false
    t.string   "email",       :limit => 70
    t.string   "message"
    t.datetime "expire"
    t.integer  "ban_creator",                                      :null => false
  end

  create_table "censors", :force => true do |t|
    t.string "source_word", :limit => 60, :null => false
    t.string "dest_word",   :limit => 60, :null => false
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                                 :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 25
    t.string   "guid",              :limit => 10
    t.integer  "locale",            :limit => 1,  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
  add_index "ckeditor_assets", ["user_id"], :name => "fk_user"

  create_table "configs", :force => true do |t|
    t.string "name",  :null => false
    t.text   "value"
  end

  create_table "forum_messes", :force => true do |t|
    t.datetime "created",  :null => false
    t.text     "message",  :null => false
    t.integer  "id_topic", :null => false
    t.integer  "id_user",  :null => false
  end

  add_index "forum_messes", ["id_topic"], :name => "forum_messes_id_topic_fkey"
  add_index "forum_messes", ["id_user"], :name => "forum_messes_id_user_fkey"

  create_table "forum_perms", :force => true do |t|
    t.integer "group_id",                           :null => false
    t.integer "subpartition_id",                    :null => false
    t.boolean "read_forum",      :default => false, :null => false
    t.boolean "post_replies",    :default => false, :null => false
    t.boolean "post_topics",     :default => false, :null => false
  end

  create_table "groups", :force => true do |t|
    t.string  "name",                         :limit => 50,                    :null => false
    t.string  "title_name",                   :limit => 50
    t.boolean "g_moderator",                                :default => false
    t.boolean "g_mod_edit_users",                           :default => false
    t.boolean "g_mod_rename_users",                         :default => false
    t.boolean "g_mod_change_password",                      :default => false
    t.boolean "g_mod_ban_users",                            :default => false
    t.boolean "g_read_board",                               :default => true
    t.boolean "g_view_users",                               :default => true
    t.boolean "g_post_replies",                             :default => true
    t.boolean "g_post_topics",                              :default => true
    t.boolean "g_edit_posts",                               :default => true
    t.boolean "g_delete_posts",                             :default => true
    t.boolean "g_delete_topics",                            :default => true
    t.boolean "g_set_title",                                :default => true
    t.boolean "g_search",                                   :default => true
    t.boolean "g_search_users",                             :default => true
    t.boolean "g_send_email",                               :default => true
    t.integer "g_post_flood",                 :limit => 2,  :default => 30,    :null => false
    t.integer "g_search_flood",               :limit => 2,  :default => 30,    :null => false
    t.integer "g_email_flood",                :limit => 2,  :default => 60,    :null => false
    t.boolean "attach_allow_download",                      :default => false
    t.boolean "attach_allow_upload",                        :default => false
    t.boolean "attach_allow_delete_own",                    :default => false
    t.integer "attach_upload_max_size"
    t.integer "attach_files_per_post",                      :default => 1
    t.text    "attach_disallowed_extensions"
    t.boolean "is_moder_in_group",                          :default => false
    t.boolean "is_admin",                                   :default => false
    t.boolean "is_guest",                                   :default => false
  end

  create_table "onlines", :force => true do |t|
    t.integer  "user_id",                   :default => 0, :null => false
    t.string   "name",        :limit => 25,                :null => false
    t.text     "prev_url"
    t.datetime "last_visit",                               :null => false
    t.datetime "last_post"
    t.datetime "last_search"
  end

  create_table "partitions", :force => true do |t|
    t.string  "title",                   :null => false
    t.integer "part_pos", :default => 0, :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "topic_id",                                          :null => false
    t.string   "poster",       :limit => 25,                        :null => false
    t.integer  "poster_id",                                         :null => false
    t.text     "message"
    t.datetime "posted",                                            :null => false
    t.datetime "edited"
    t.string   "edited_by",    :limit => 25
    t.string   "poster_ip",    :limit => 15, :default => "0.0.0.0"
    t.string   "poster_email", :limit => 70
  end

  create_table "private_mes", :force => true do |t|
    t.integer  "id_sender",                        :null => false
    t.integer  "id_receiver",                      :null => false
    t.string   "title",                            :null => false
    t.text     "body",                             :null => false
    t.datetime "send_datetime",                    :null => false
    t.boolean  "isread",        :default => false
  end

  add_index "private_mes", ["id_receiver"], :name => "private_mes_id_receiver_fkey"
  add_index "private_mes", ["id_sender"], :name => "private_mes_id_sender_fkey"

  create_table "ranks", :force => true do |t|
    t.string  "rank",         :limit => 50, :null => false
    t.integer "num_of_posts",               :null => false
  end

  create_table "reports", :force => true do |t|
    t.integer  "post_id",         :null => false
    t.integer  "topic_id",        :null => false
    t.integer  "subpartition_id", :null => false
    t.integer  "user_id",         :null => false
    t.datetime "created_at",      :null => false
    t.text     "message"
    t.datetime "readed_at"
    t.integer  "readed_by"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subpartitions", :force => true do |t|
    t.integer  "partition_id",                :null => false
    t.string   "title",                       :null => false
    t.string   "desc"
    t.integer  "part_pos",     :default => 0, :null => false
    t.datetime "last_post"
    t.integer  "last_post_id"
    t.string   "last_poster"
    t.integer  "num_posts",    :default => 0, :null => false
    t.integer  "num_topics",   :default => 0, :null => false
  end

  create_table "subpartitions_users", :id => false, :force => true do |t|
    t.integer "subpartition_id", :null => false
    t.integer "user_id",         :null => false
  end

  create_table "topics", :force => true do |t|
    t.integer  "subpartition_id",                                  :null => false
    t.string   "poster",          :limit => 25,                    :null => false
    t.string   "title",                                            :null => false
    t.integer  "first_post_id",                                    :null => false
    t.datetime "last_post",                                        :null => false
    t.integer  "last_post_id",                                     :null => false
    t.string   "last_poster",     :limit => 25,                    :null => false
    t.integer  "num_views",                                        :null => false
    t.integer  "num_replies",                                      :null => false
    t.boolean  "closed",                        :default => false, :null => false
    t.boolean  "sticky",                        :default => false, :null => false
    t.integer  "moved_to",                                         :null => false
    t.integer  "poster_id",                     :default => 1,     :null => false
  end

  add_index "topics", ["subpartition_id"], :name => "topics_subpartition_id_fkey"

  create_table "users", :force => true do |t|
    t.string   "name",                :limit => 25,                          :null => false
    t.string   "passwd",              :limit => 32,                          :null => false
    t.string   "email",               :limit => 70,                          :null => false
    t.datetime "regdatetime",                                                :null => false
    t.string   "salt",                :limit => 5,                           :null => false
    t.string   "realname",            :limit => 100
    t.string   "location",            :limit => 100
    t.string   "web"
    t.text     "signature"
    t.string   "jabber",              :limit => 50
    t.string   "icq",                 :limit => 15
    t.string   "msn",                 :limit => 50
    t.string   "aim",                 :limit => 30
    t.string   "yahoo",               :limit => 30
    t.string   "forum_style",         :limit => 50
    t.boolean  "smiles_to_img",                      :default => true
    t.boolean  "show_users_sign",                    :default => true
    t.boolean  "show_img_inmess",                    :default => true
    t.boolean  "show_img_insign",                    :default => true
    t.integer  "themes_per_page"
    t.integer  "posts_per_page"
    t.string   "timezone",            :limit => 80
    t.string   "forum_lang",          :limit => 10
    t.string   "howshowemail",        :limit => 1
    t.string   "title",               :limit => 50
    t.integer  "group_id",                                                   :null => false
    t.string   "registration_ip",     :limit => 20,  :default => "0.0.0.0",  :null => false
    t.string   "date_format",         :limit => 30,  :default => "%Y-%m-%d", :null => false
    t.string   "time_format",         :limit => 30,  :default => "%H:%M:%S", :null => false
    t.string   "adminnote"
    t.integer  "numposts",                           :default => 0,          :null => false
    t.boolean  "dst",                                :default => false,      :null => false
    t.datetime "last_visit"
    t.string   "last_page"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "last_post"
    t.datetime "last_search"
    t.datetime "last_email_sent"
    t.boolean  "remind_pass_sended",                 :default => false
  end

  add_foreign_key "forum_messes", ["id_topic"], "topics", ["id"], :name => "forum_messes_id_topic_fkey"
  add_foreign_key "forum_messes", ["id_user"], "users", ["id"], :name => "forum_messes_id_user_fkey"

  add_foreign_key "private_mes", ["id_receiver"], "users", ["id"], :name => "private_mes_id_receiver_fkey"
  add_foreign_key "private_mes", ["id_sender"], "users", ["id"], :name => "private_mes_id_sender_fkey"

  add_foreign_key "topics", ["subpartition_id"], "subpartitions", ["id"], :name => "topics_subpartition_id_fkey"

end
