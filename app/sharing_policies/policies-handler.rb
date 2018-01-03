# module Sharing_policies
#
# class Policies_handler
#
# def add_policies(uid, relation_type, allowed_aspects )
#
#                  # sl_friends, sl_family, sl_coworks, sl_acquaintances, sl_pic_item, sl_mention_item,
#                  # sl_location_item,trust_friend, trust_fmaily, trust_coworkers, trust_acquaintances , tr_threshold,
#                  # to_friend_stakeholder, to_family_stakeholder, to_coworker_stakeholder, to_acquaintances_stakeholder)
#
# # data for shared_privacy_policy model
#  # Take the input from the user
#   shared_policies_allowed_aspects = AllowedAspects.new(:user_id => uid, :relationship_type => relation_type, :allowed_aspects=> allowed_aspects)
#
#   shared_policies_allowed_aspects.save
#
#   # shared_policies_sensitivity_of_items = SharedPrivacyPolicy.new (:user_id => uid,
#   #                                                                 :sensitive_level_of_pic_post => sl_pic_item,
#   #                                                                 :sensitive_level_of_metions_post => sl_mention_item,
#   #                                                                 :sensitive_level_of_locations_post => sl_location_item)
#   # shared_policies_sensitivity_of_items.save
#
#   # # Sensitive_level and trust_level for user aspects
#   #
#   # s_t_levels_Fa=Aspect.where(:user_id => uid, :name => "Family").update_attributes (:sensitive_level => sl_family, :trust_level => trust_fmaily)
#   # s_t_levels_Fr=Aspect.where(:user_id => uid, :name => "Friends").update_attributes (:sensitive_level => sl_friends, :trust_level => trust_friend)
#   # s_t_levels_Cw=Aspect.where(:user_id => uid, :name => "Work").update_attributes (:sensitive_level => sl_coworks, :trust_level=> trust_coworkers )
#   # s_t_levels_Ac=Aspect.where(:user_id => uid, :name => "Acquaintances").update_attributes (:sensitive_level => sl_acquaintances, :trust_level => trust_acquaintances)
#
#   # # trust thtreshold value to reshare
#   #
#   # trust_threshold=Person.where(:id => uid).update_attributes(:tr_threshold => tr_threshold)
#   #
#   # reshare_policies=ControllersSharingVoting.new(:user_id=> uid, :acquaintances_stakeholder=>to_acquaintances_stakeholder== "yes" ? 1 : 0,
#   #                                               :friend_stakeholder => to_friend_stakeholder=="yes" ? 1 : 0,
#   #                                               :family_stakeholder => to_family_stakeholder == "yes" ? 1 : 0,
#   #                                               :coworker_stakeholder => to_coworker_stakeholder == "yes" ? 1 : 0)
#   # reshare_policies.save
#
#   end
#
#   # don't need to delete the policies in my model ??
#   # def delete_policies(uid)
#   # policy = PrivacyPolicy.where(:user_id => uid,
#   #                              :shareable_type => shareable).first
#   # policy.destroy if policy != nil
#   # return "Diaspora is **NOT** protecting your " + shareable
#   # end
#
#   def reset_policies_h(uid,relation_type)
#
#      AllowedAspects.where(:user_id => uid, :relationship_type => relation_type).find_each do |aspect_id|
#     aspect_id.destroy
#     end
#
#     # PrivacyPolicy.where(:user_id => uid,
#     #                     :shareable_type => shareable).find_each do |policy|
#       policy.destroy
#   end
#
#    def get_user_aspect_ids_h(uid)
#      aspects_temp = Aspect.where(:user_id => uid)
#       aspects = []
#       aspects_temp.each do |a|
#        aspects = aspects.push(a.id)
#        end
#        return aspects
#    end
#
#    def get_user_allowed_aspects_h(uid, relation_type)
#      the_allowed_aspects = AllowedAspects.where(:user_id => uid,
#                                                   :relationship_type => relation_type)
#        if the_allowed_aspects.collect{|pp| pp.allowed_aspectids}.include? -1
#          return [-1]
#       else
#           # aspects = get_user_aspect_ids(uid)
#          return the_allowed_aspects.collect{|pp| pp.allowed_aspectids}
#        end
#     end
# end
# end
