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

ActiveRecord::Schema.define(:version => 20171229141218) do

  create_table "account_deletions", :force => true do |t|
    t.string  "diaspora_handle"
    t.integer "person_id"
  end

  create_table "allowed_aspects", :force => true do |t|
    t.integer  "user_id"
    t.string   "relationship_type"
    t.integer  "allowed_aspectids"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "aspect_memberships", :force => true do |t|
    t.integer  "aspect_id",  :null => false
    t.integer  "contact_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "aspect_memberships", ["aspect_id", "contact_id"], :name => "index_aspect_memberships_on_aspect_id_and_contact_id", :unique => true
  add_index "aspect_memberships", ["aspect_id"], :name => "index_aspect_memberships_on_aspect_id"
  add_index "aspect_memberships", ["contact_id"], :name => "index_aspect_memberships_on_contact_id"

  create_table "aspect_visibilities", :force => true do |t|
    t.integer  "shareable_id",                       :null => false
    t.integer  "aspect_id",                          :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "shareable_type", :default => "Post", :null => false
  end

  add_index "aspect_visibilities", ["aspect_id"], :name => "index_aspect_visibilities_on_aspect_id"
  add_index "aspect_visibilities", ["shareable_id", "shareable_type", "aspect_id"], :name => "shareable_and_aspect_id"
  add_index "aspect_visibilities", ["shareable_id", "shareable_type"], :name => "index_aspect_visibilities_on_shareable_id_and_shareable_type"

  create_table "aspects", :force => true do |t|
    t.string   "name",                                                             :null => false
    t.integer  "user_id",                                                          :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.boolean  "contacts_visible",                               :default => true, :null => false
    t.integer  "order_id"
    t.decimal  "sensitive_level",  :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "trust_level",      :precision => 5, :scale => 2, :default => 0.0
  end

  add_index "aspects", ["user_id", "contacts_visible"], :name => "index_aspects_on_user_id_and_contacts_visible"
  add_index "aspects", ["user_id"], :name => "index_aspects_on_user_id"

  create_table "aspects_levels_of_senstivity_and_trusts", :force => true do |t|
    t.integer  "user_id"
    t.string   "relationship_type"
    t.decimal  "sensitive_level",   :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "trust_level",       :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "o_auth_application_id"
    t.string   "refresh_token"
    t.string   "code"
    t.string   "redirect_uri"
    t.string   "nonce"
    t.string   "scopes"
    t.boolean  "code_used",             :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "authorizations", ["o_auth_application_id"], :name => "index_authorizations_on_o_auth_application_id"
  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "blocks", :force => true do |t|
    t.integer "user_id"
    t.integer "person_id"
  end

  create_table "chat_contacts", :force => true do |t|
    t.integer "user_id",                     :null => false
    t.string  "jid",                         :null => false
    t.string  "name"
    t.string  "ask",          :limit => 128
    t.string  "subscription", :limit => 128, :null => false
  end

  add_index "chat_contacts", ["user_id", "jid"], :name => "index_chat_contacts_on_user_id_and_jid", :unique => true, :length => {"user_id"=>nil, "jid"=>190}

  create_table "chat_fragments", :force => true do |t|
    t.integer "user_id",                  :null => false
    t.string  "root",      :limit => 256, :null => false
    t.string  "namespace", :limit => 256, :null => false
    t.text    "xml",                      :null => false
  end

  add_index "chat_fragments", ["user_id"], :name => "index_chat_fragments_on_user_id", :unique => true

  create_table "chat_offline_messages", :force => true do |t|
    t.string   "from",       :null => false
    t.string   "to",         :null => false
    t.text     "message",    :null => false
    t.datetime "created_at", :null => false
  end

  create_table "comment_signatures", :id => false, :force => true do |t|
    t.integer "comment_id",         :null => false
    t.text    "author_signature",   :null => false
    t.integer "signature_order_id", :null => false
    t.text    "additional_data"
  end

  add_index "comment_signatures", ["comment_id"], :name => "index_comment_signatures_on_comment_id", :unique => true
  add_index "comment_signatures", ["signature_order_id"], :name => "comment_signatures_signature_orders_id_fk"

  create_table "comments", :force => true do |t|
    t.text     "text",                                                      :null => false
    t.integer  "commentable_id",                                            :null => false
    t.integer  "author_id",                                                 :null => false
    t.string   "guid",                                                      :null => false
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "likes_count",                           :default => 0,      :null => false
    t.string   "commentable_type",        :limit => 60, :default => "Post", :null => false
  end

  add_index "comments", ["author_id"], :name => "index_comments_on_person_id"
  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["guid"], :name => "index_comments_on_guid", :unique => true

  create_table "contacts", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "person_id",                     :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "sharing",    :default => false, :null => false
    t.boolean  "receiving",  :default => false, :null => false
  end

  add_index "contacts", ["person_id"], :name => "index_contacts_on_person_id"
  add_index "contacts", ["user_id", "person_id"], :name => "index_contacts_on_user_id_and_person_id", :unique => true

  create_table "controllers_resharing_votings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "allowed_aspects_ids"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "conversation_visibilities", :force => true do |t|
    t.integer  "conversation_id",                :null => false
    t.integer  "person_id",                      :null => false
    t.integer  "unread",          :default => 0, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "conversation_visibilities", ["conversation_id", "person_id"], :name => "index_conversation_visibilities_usefully", :unique => true
  add_index "conversation_visibilities", ["conversation_id"], :name => "index_conversation_visibilities_on_conversation_id"
  add_index "conversation_visibilities", ["person_id"], :name => "index_conversation_visibilities_on_person_id"

  create_table "conversations", :force => true do |t|
    t.string   "subject"
    t.string   "guid",       :null => false
    t.integer  "author_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "conversations", ["author_id"], :name => "conversations_author_id_fk"

  create_table "disallowed_aspects", :force => true do |t|
    t.integer  "user_id"
    t.string   "relationship_type"
    t.integer  "disallowed_aspectids"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "invitation_codes", :force => true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.integer  "count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "invitations", :force => true do |t|
    t.text     "message"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "aspect_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "service"
    t.string   "identifier"
    t.boolean  "admin",        :default => false
    t.string   "language",     :default => "en"
  end

  add_index "invitations", ["aspect_id"], :name => "index_invitations_on_aspect_id"
  add_index "invitations", ["recipient_id"], :name => "index_invitations_on_recipient_id"
  add_index "invitations", ["sender_id"], :name => "index_invitations_on_sender_id"

  create_table "like_signatures", :id => false, :force => true do |t|
    t.integer "like_id",            :null => false
    t.text    "author_signature",   :null => false
    t.integer "signature_order_id", :null => false
    t.text    "additional_data"
  end

  add_index "like_signatures", ["like_id"], :name => "index_like_signatures_on_like_id", :unique => true
  add_index "like_signatures", ["signature_order_id"], :name => "like_signatures_signature_orders_id_fk"

  create_table "likes", :force => true do |t|
    t.boolean  "positive",                              :default => true
    t.integer  "target_id"
    t.integer  "author_id"
    t.string   "guid"
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "target_type",             :limit => 60,                   :null => false
  end

  add_index "likes", ["author_id"], :name => "likes_author_id_fk"
  add_index "likes", ["guid"], :name => "index_likes_on_guid", :unique => true
  add_index "likes", ["target_id", "author_id", "target_type"], :name => "index_likes_on_target_id_and_author_id_and_target_type", :unique => true
  add_index "likes", ["target_id"], :name => "index_likes_on_post_id"

  create_table "locations", :force => true do |t|
    t.string   "address"
    t.string   "lat"
    t.string   "lng"
    t.integer  "status_message_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "mentions", :force => true do |t|
    t.integer "post_id",   :null => false
    t.integer "person_id", :null => false
  end

  add_index "mentions", ["person_id", "post_id"], :name => "index_mentions_on_person_id_and_post_id", :unique => true
  add_index "mentions", ["person_id"], :name => "index_mentions_on_person_id"
  add_index "mentions", ["post_id"], :name => "index_mentions_on_post_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id",         :null => false
    t.integer  "author_id",               :null => false
    t.string   "guid",                    :null => false
    t.text     "text",                    :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.text     "author_signature"
    t.text     "parent_author_signature"
  end

  add_index "messages", ["author_id"], :name => "index_messages_on_author_id"
  add_index "messages", ["conversation_id"], :name => "messages_conversation_id_fk"

  create_table "notification_actors", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "person_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "notification_actors", ["notification_id", "person_id"], :name => "index_notification_actors_on_notification_id_and_person_id", :unique => true
  add_index "notification_actors", ["notification_id"], :name => "index_notification_actors_on_notification_id"
  add_index "notification_actors", ["person_id"], :name => "index_notification_actors_on_person_id"

  create_table "notifications", :force => true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "recipient_id",                   :null => false
    t.boolean  "unread",       :default => true, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "type"
  end

  add_index "notifications", ["recipient_id"], :name => "index_notifications_on_recipient_id"
  add_index "notifications", ["target_id"], :name => "index_notifications_on_target_id"
  add_index "notifications", ["target_type", "target_id"], :name => "index_notifications_on_target_type_and_target_id"

  create_table "o_auth_access_tokens", :force => true do |t|
    t.integer  "authorization_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "o_auth_access_tokens", ["authorization_id"], :name => "index_o_auth_access_tokens_on_authorization_id"
  add_index "o_auth_access_tokens", ["token"], :name => "index_o_auth_access_tokens_on_token", :unique => true, :length => {"token"=>191}

  create_table "o_auth_applications", :force => true do |t|
    t.integer  "user_id"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "client_name"
    t.text     "redirect_uris"
    t.string   "response_types"
    t.string   "grant_types"
    t.string   "application_type",           :default => "web"
    t.string   "contacts"
    t.string   "logo_uri"
    t.string   "client_uri"
    t.string   "policy_uri"
    t.string   "tos_uri"
    t.string   "sector_identifier_uri"
    t.string   "token_endpoint_auth_method"
    t.text     "jwks"
    t.string   "jwks_uri"
    t.boolean  "ppid",                       :default => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "o_auth_applications", ["client_id"], :name => "index_o_auth_applications_on_client_id", :unique => true, :length => {"client_id"=>191}
  add_index "o_auth_applications", ["user_id"], :name => "index_o_auth_applications_on_user_id"

  create_table "o_embed_caches", :force => true do |t|
    t.string "url",  :limit => 1024, :null => false
    t.text   "data",                 :null => false
  end

  add_index "o_embed_caches", ["url"], :name => "index_o_embed_caches_on_url", :length => {"url"=>255}

  create_table "open_graph_caches", :force => true do |t|
    t.string "title"
    t.string "ob_type"
    t.string "image"
    t.string "url"
    t.text   "description"
  end

  create_table "participations", :force => true do |t|
    t.string   "guid"
    t.integer  "target_id"
    t.string   "target_type",             :limit => 60, :null => false
    t.integer  "author_id"
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "participations", ["guid"], :name => "index_participations_on_guid"
  add_index "participations", ["target_id", "target_type", "author_id"], :name => "index_participations_on_target_id_and_target_type_and_author_id"

  create_table "people", :force => true do |t|
    t.string   "guid",                                                                   :null => false
    t.text     "url",                                                                    :null => false
    t.string   "diaspora_handle",                                                        :null => false
    t.text     "serialized_public_key",                                                  :null => false
    t.integer  "owner_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "closed_account",                                      :default => false
    t.integer  "fetch_status",                                        :default => 0
    t.decimal  "sensitive_level",       :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "tr_threshold",          :precision => 5, :scale => 2, :default => 0.0
  end

  add_index "people", ["diaspora_handle"], :name => "index_people_on_diaspora_handle", :unique => true
  add_index "people", ["guid"], :name => "index_people_on_guid", :unique => true
  add_index "people", ["owner_id"], :name => "index_people_on_owner_id", :unique => true

  create_table "photos", :force => true do |t|
    t.integer  "tmp_old_id"
    t.integer  "author_id",                              :null => false
    t.boolean  "public",              :default => false, :null => false
    t.string   "diaspora_handle"
    t.string   "guid",                                   :null => false
    t.boolean  "pending",             :default => false, :null => false
    t.text     "text"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "processed_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unprocessed_image"
    t.string   "status_message_guid"
    t.integer  "comments_count"
    t.integer  "height"
    t.integer  "width"
  end

  add_index "photos", ["status_message_guid"], :name => "index_photos_on_status_message_guid"

  create_table "pods", :force => true do |t|
    t.string   "host"
    t.boolean  "ssl"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "poll_answers", :force => true do |t|
    t.string  "answer",                    :null => false
    t.integer "poll_id",                   :null => false
    t.string  "guid"
    t.integer "vote_count", :default => 0
  end

  add_index "poll_answers", ["poll_id"], :name => "index_poll_answers_on_poll_id"

  create_table "poll_participation_signatures", :id => false, :force => true do |t|
    t.integer "poll_participation_id", :null => false
    t.text    "author_signature",      :null => false
    t.integer "signature_order_id",    :null => false
    t.text    "additional_data"
  end

  add_index "poll_participation_signatures", ["poll_participation_id"], :name => "index_poll_participation_signatures_on_poll_participation_id", :unique => true
  add_index "poll_participation_signatures", ["signature_order_id"], :name => "poll_participation_signatures_signature_orders_id_fk"

  create_table "poll_participations", :force => true do |t|
    t.integer  "poll_answer_id",          :null => false
    t.integer  "author_id",               :null => false
    t.integer  "poll_id",                 :null => false
    t.string   "guid"
    t.text     "author_signature"
    t.text     "parent_author_signature"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "poll_participations", ["poll_id"], :name => "index_poll_participations_on_poll_id"

  create_table "polls", :force => true do |t|
    t.string   "question",          :null => false
    t.integer  "status_message_id", :null => false
    t.boolean  "status"
    t.string   "guid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "polls", ["status_message_id"], :name => "index_polls_on_status_message_id"

  create_table "posts", :force => true do |t|
    t.integer  "author_id",                                              :null => false
    t.boolean  "public",                              :default => false, :null => false
    t.string   "diaspora_handle"
    t.string   "guid",                                                   :null => false
    t.boolean  "pending",                             :default => false, :null => false
    t.string   "type",                  :limit => 40,                    :null => false
    t.text     "text"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "random_string"
    t.string   "processed_image"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "unprocessed_image"
    t.string   "object_url"
    t.string   "image_url"
    t.integer  "image_height"
    t.integer  "image_width"
    t.string   "provider_display_name"
    t.string   "actor_url"
    t.string   "objectId"
    t.string   "root_guid"
    t.string   "status_message_guid"
    t.integer  "likes_count",                         :default => 0
    t.integer  "comments_count",                      :default => 0
    t.integer  "o_embed_cache_id"
    t.integer  "reshares_count",                      :default => 0
    t.datetime "interacted_at"
    t.string   "frame_name"
    t.boolean  "favorite",                            :default => false
    t.string   "facebook_id"
    t.string   "tweet_id"
    t.integer  "open_graph_cache_id"
    t.text     "tumblr_ids"
  end

  add_index "posts", ["author_id", "root_guid"], :name => "index_posts_on_author_id_and_root_guid", :unique => true
  add_index "posts", ["author_id"], :name => "index_posts_on_person_id"
  add_index "posts", ["guid"], :name => "index_posts_on_guid", :unique => true
  add_index "posts", ["id", "type", "created_at"], :name => "index_posts_on_id_and_type_and_created_at"
  add_index "posts", ["root_guid"], :name => "index_posts_on_root_guid"
  add_index "posts", ["status_message_guid", "pending"], :name => "index_posts_on_status_message_guid_and_pending"
  add_index "posts", ["status_message_guid"], :name => "index_posts_on_status_message_guid"
  add_index "posts", ["tweet_id"], :name => "index_posts_on_tweet_id"
  add_index "posts", ["type", "pending", "id"], :name => "index_posts_on_type_and_pending_and_id"

  create_table "posts_sensitive_levels", :force => true do |t|
    t.integer  "user_id"
    t.string   "post_type"
    t.decimal  "sensitive_level", :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "ppid", :force => true do |t|
    t.integer "o_auth_application_id"
    t.integer "user_id"
    t.string  "guid",                  :limit => 32
    t.string  "string",                :limit => 32
    t.string  "identifier"
  end

  add_index "ppid", ["o_auth_application_id"], :name => "index_ppid_on_o_auth_application_id"
  add_index "ppid", ["user_id"], :name => "index_ppid_on_user_id"

  create_table "privacy_policies", :force => true do |t|
    t.integer  "user_id"
    t.string   "shareable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "allowed_aspect"
    t.boolean  "block"
    t.boolean  "hide"
  end

  create_table "profiles", :force => true do |t|
    t.string   "diaspora_handle"
    t.string   "first_name",       :limit => 127
    t.string   "last_name",        :limit => 127
    t.string   "image_url"
    t.string   "image_url_small"
    t.string   "image_url_medium"
    t.date     "birthday"
    t.string   "gender"
    t.text     "bio"
    t.boolean  "searchable",                      :default => true,  :null => false
    t.integer  "person_id",                                          :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "location"
    t.string   "full_name",        :limit => 70
    t.boolean  "nsfw",                            :default => false
  end

  add_index "profiles", ["full_name", "searchable"], :name => "index_profiles_on_full_name_and_searchable"
  add_index "profiles", ["full_name"], :name => "index_profiles_on_full_name"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "reports", :force => true do |t|
    t.integer  "item_id",                       :null => false
    t.string   "item_type",                     :null => false
    t.boolean  "reviewed",   :default => false
    t.text     "text"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "user_id",                       :null => false
  end

  add_index "reports", ["item_id"], :name => "index_post_reports_on_post_id"

  create_table "roles", :force => true do |t|
    t.integer  "person_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sensitive_level_policies", :force => true do |t|
    t.string  "relationship_type"
    t.integer "user_id"
    t.string  "sensitive_level"
    t.integer "allowed_aspectid"
  end

  add_index "sensitive_level_policies", ["user_id"], :name => "sensitive_level_policies_user_id_uindex", :unique => true

  create_table "services", :force => true do |t|
    t.string   "type",          :limit => 127, :null => false
    t.integer  "user_id",                      :null => false
    t.string   "uid",           :limit => 127
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "nickname"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "services", ["type", "uid"], :name => "index_services_on_type_and_uid"
  add_index "services", ["user_id"], :name => "index_services_on_user_id"

  create_table "share_visibilities", :force => true do |t|
    t.integer  "shareable_id",                                     :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.boolean  "hidden",                       :default => false,  :null => false
    t.integer  "contact_id",                                       :null => false
    t.string   "shareable_type", :limit => 60, :default => "Post", :null => false
  end

  add_index "share_visibilities", ["contact_id"], :name => "index_post_visibilities_on_contact_id"
  add_index "share_visibilities", ["shareable_id", "shareable_type", "contact_id"], :name => "shareable_and_contact_id"
  add_index "share_visibilities", ["shareable_id", "shareable_type", "hidden", "contact_id"], :name => "shareable_and_hidden_and_contact_id"
  add_index "share_visibilities", ["shareable_id"], :name => "index_post_visibilities_on_post_id"

  create_table "shared_privacy_policies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "allowed_aspectid_when_owner_friend"
    t.integer  "allowed_aspectid_when_owner_family"
    t.integer  "allowed_aspectid_when_owner_acquaintances"
    t.integer  "allowed_aspectid_when_owner_coworker"
    t.decimal  "sensitive_level_of_metions_post",           :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "sensitive_level_of_locations_post",         :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "sensitive_level_of_pic_post",               :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
  end

  create_table "signature_orders", :force => true do |t|
    t.string "order", :null => false
  end

  add_index "signature_orders", ["order"], :name => "index_signature_orders_on_order", :unique => true, :length => {"order"=>191}

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "tag_followings", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tag_followings", ["tag_id", "user_id"], :name => "index_tag_followings_on_tag_id_and_user_id", :unique => true
  add_index "tag_followings", ["tag_id"], :name => "index_tag_followings_on_tag_id"
  add_index "tag_followings", ["user_id"], :name => "index_tag_followings_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 127
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 127
    t.string   "context",       :limit => 127
    t.datetime "created_at"
  end

  add_index "taggings", ["created_at"], :name => "index_taggings_on_created_at"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
  add_index "taggings", ["taggable_id", "taggable_type", "tag_id"], :name => "index_taggings_uniquely", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "user_preferences", :force => true do |t|
    t.string   "email_type"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.text     "serialized_private_key"
    t.boolean  "getting_started",                                   :default => true,  :null => false
    t.boolean  "disable_mail",                                      :default => false, :null => false
    t.string   "language"
    t.string   "email",                                             :default => "",    :null => false
    t.string   "encrypted_password",                                :default => "",    :null => false
    t.string   "invitation_token",                   :limit => 60
    t.datetime "invitation_sent_at"
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                     :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "invitation_service",                 :limit => 127
    t.string   "invitation_identifier",              :limit => 127
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "authentication_token",               :limit => 30
    t.string   "unconfirmed_email"
    t.string   "confirm_email_token",                :limit => 30
    t.datetime "locked_at"
    t.boolean  "show_community_spotlight_in_stream",                :default => true,  :null => false
    t.boolean  "auto_follow_back",                                  :default => false
    t.integer  "auto_follow_back_aspect_id"
    t.text     "hidden_shareables"
    t.datetime "reset_password_sent_at"
    t.datetime "last_seen"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["invitation_service", "invitation_identifier"], :name => "index_users_on_invitation_service_and_invitation_identifier", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  add_foreign_key "aspect_memberships", "aspects", name: "aspect_memberships_aspect_id_fk", dependent: :delete
  add_foreign_key "aspect_memberships", "contacts", name: "aspect_memberships_contact_id_fk", dependent: :delete

  add_foreign_key "aspect_visibilities", "aspects", name: "aspect_visibilities_aspect_id_fk", dependent: :delete

  add_foreign_key "authorizations", "o_auth_applications", name: "fk_rails_e166644de5"
  add_foreign_key "authorizations", "users", name: "fk_rails_4ecef5b8c5"

  add_foreign_key "comment_signatures", "comments", name: "comment_signatures_comment_id_fk", dependent: :delete
  add_foreign_key "comment_signatures", "signature_orders", name: "comment_signatures_signature_orders_id_fk"

  add_foreign_key "comments", "people", name: "comments_author_id_fk", column: "author_id", dependent: :delete

  add_foreign_key "contacts", "people", name: "contacts_person_id_fk", dependent: :delete

  add_foreign_key "conversation_visibilities", "conversations", name: "conversation_visibilities_conversation_id_fk", dependent: :delete
  add_foreign_key "conversation_visibilities", "people", name: "conversation_visibilities_person_id_fk", dependent: :delete

  add_foreign_key "conversations", "people", name: "conversations_author_id_fk", column: "author_id", dependent: :delete

  add_foreign_key "invitations", "users", name: "invitations_recipient_id_fk", column: "recipient_id", dependent: :delete
  add_foreign_key "invitations", "users", name: "invitations_sender_id_fk", column: "sender_id", dependent: :delete

  add_foreign_key "like_signatures", "likes", name: "like_signatures_like_id_fk", dependent: :delete
  add_foreign_key "like_signatures", "signature_orders", name: "like_signatures_signature_orders_id_fk"

  add_foreign_key "likes", "people", name: "likes_author_id_fk", column: "author_id", dependent: :delete

  add_foreign_key "messages", "conversations", name: "messages_conversation_id_fk", dependent: :delete
  add_foreign_key "messages", "people", name: "messages_author_id_fk", column: "author_id", dependent: :delete

  add_foreign_key "notification_actors", "notifications", name: "notification_actors_notification_id_fk", dependent: :delete

  add_foreign_key "o_auth_access_tokens", "authorizations", name: "fk_rails_5debabcff3"

  add_foreign_key "o_auth_applications", "users", name: "fk_rails_ad75323da2"

  add_foreign_key "poll_participation_signatures", "poll_participations", name: "poll_participation_signatures_poll_participation_id_fk", dependent: :delete
  add_foreign_key "poll_participation_signatures", "signature_orders", name: "poll_participation_signatures_signature_orders_id_fk"

  add_foreign_key "posts", "people", name: "posts_author_id_fk", column: "author_id", dependent: :delete

  add_foreign_key "ppid", "o_auth_applications", name: "fk_rails_150457f962"
  add_foreign_key "ppid", "users", name: "fk_rails_e6b8e5264f"

  add_foreign_key "profiles", "people", name: "profiles_person_id_fk", dependent: :delete

  add_foreign_key "services", "users", name: "services_user_id_fk", dependent: :delete

  add_foreign_key "share_visibilities", "contacts", name: "post_visibilities_contact_id_fk", dependent: :delete

end
