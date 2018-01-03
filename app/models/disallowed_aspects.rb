class DisallowedAspects < ActiveRecord::Base
  attr_accessible :disallowed_aspectids, :relationship_type, :user_id
end
