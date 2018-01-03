class AllowedAspects < ActiveRecord::Base
  attr_accessible :allowed_aspectids, :relationship_type, :user_id
end
