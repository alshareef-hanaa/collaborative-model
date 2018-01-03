class ControllersResharingVoting < ActiveRecord::Base
  attr_accessible :allowed_aspects_ids, :user_id
end
