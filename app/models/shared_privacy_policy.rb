class SharedPrivacyPolicy < ActiveRecord::Base
  attr_accessible :allowed_aspectid_when_owner_acquaintances, :allowed_aspectid_when_owner_coworker, :allowed_aspectid_when_owner_family, :allowed_aspectid_when_owner_friend, :sensitive_level_of_locations_post, :sensitive_level_of_metions_post, :sensitive_level_of_pic_post, :user_id
end
