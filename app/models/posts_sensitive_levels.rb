class PostsSensitiveLevels < ActiveRecord::Base
  attr_accessible :post_type, :sensitive_level, :user_id
end
