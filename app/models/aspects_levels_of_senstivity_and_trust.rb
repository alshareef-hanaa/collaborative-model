class AspectsLevelsOfSenstivityAndTrust < ActiveRecord::Base
  attr_accessible :relationship_type, :sensitive_level, :trust_level, :user_id
end
