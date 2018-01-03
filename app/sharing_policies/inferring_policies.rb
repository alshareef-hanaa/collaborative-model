#  module Sharing_Policies
#     class Inferring_Policies
#
#
#       def inferring_stakeholders_policies(params)
#         policies =[ ]
#
#         # Getting the mentioned people in the post
#         ppl= Diaspora::Mentionable.people_from_string(params[:status_message][:text])
#         ppl.each do |p|
#           # retrieve relationship type between stakeholder and owner
#           t= rt(p,params[:status_message][:author].id)
#           relationship_type=relationship_type.to_s
#           # retrieve sensitive level of this relationship type from stakeholder side
#           sensitive_level_between_stakeholder_and_owner= Aspect.where(:user_id => p.id, :name => f).select(:sensitive_level)
#           sensitive_level_between_stakeholder_and_owner = sensitive_level_between_stakeholder_and_owner.map{|e| [e.sensitive_level]}
#           sensitive_level_between_stakeholder_and_owner= sensitive_level_between_stakeholder_and_owner.flatten(1)
#
#         #  retrieve sensitive level of post
#           #if post has 2 or 3 of these items then we consider the higher sl_post to use (to do later)
#           if params[:location_address].present?
#             sensitive_level_post = SharedPrivacyPolicy.where(:user_id => p.id).select(:sensitive_level_of_locations_post).first
#             sensitive_level_post = sensitive_level_post.map{|e| [e.sensitive_level_of_locations_post]}
#             sensitive_level_post= sensitive_level_post.flatten(1)
#
#           end
#
#           if params[:photos].present?
#             sensitive_level_post = SharedPrivacyPolicy.where(:user_id => p.id).select(:sensitive_level_of_pic_post).first
#             sensitive_level_post = sensitive_level_post.map{|e| [e.sensitive_level_of_pic_post]}
#             sensitive_level_post= sensitive_level_post.flatten(1)
#           end
#
#           if ppl.length > 1 then
#             sensitive_level_post = SharedPrivacyPolicy.where(:user_id => p.id).select(:sensitive_level_of_metions_post).first
#             sensitive_level_post = sensitive_level_post.map{|e| [e.sensitive_level_of_metions_post]}
#             sensitive_level_post= sensitive_level_post.flatten(1)
#           end
#
#           # determine allowed aspects
#
#           user_aspects=Aspect.where(:user_id => p.id).select(:id)
#           user_aspects= user_aspects.map{|e| [e.id]}
#           user_aspects= user_aspects.flatten(1)
#
#           if  relationship_type == "Family"
#             allowed_aspects= SharedPrivacyPolicy.where(:user_id => p.id).select(:allowed_aspectid_when_owner_family)
#             allowed_aspects= allowed_aspects.map{|e| [e.allowed_aspectid_when_owner_family]}
#             allowed_aspects= allowed_aspects.flatten(1)
#
#           elsif relationship_type == "Friend"
#             allowed_aspects= Shared_Privacy_Policy.where(:user_id => p.id).select(:allowed_aspectid_when_owner_friend)
#             allowed_aspects= allowed_aspects.map{|e| [e.allowed_aspectid_when_owner_friend]}
#             allowed_aspects= allowed_aspects.flatten(1)
#
#           elsif relationship_type == "Work"
#             allowed_aspects= Shared_Privacy_Policy.where(:user_id => p.id).select(:allowed_aspectid_when_owner_coworker)
#             allowed_aspects= allowed_aspects.map{|e| [e.allowed_aspectid_when_owner_coworker]}
#             allowed_aspects= allowed_aspects.flatten(1)
#
#
#           elsif relationship_type == "Acquaintances"
#             allowed_aspects= Shared_Privacy_Policy.where(:user_id => p.id).select(:allowed_aspectid_when_owner_acquaintances)
#             allowed_aspects= allowed_aspects.map{|e| [e.allowed_aspectid_when_owner_acquaintances]}
#             allowed_aspects= allowed_aspects.flatten(1)
#           end
#
#           # determine disallowed aspects
#           disallowed_aspects=[ ]
#           if user_aspects.length != allowed_aspects.length
#             user_aspects.each do |dis|
#               if allowed_aspects.exclude? dis
#                 disallowed_aspects.push(dis)
#               end
#             end
#           end
#           # set policy of the stakeholder with id p
#           policy= {user_id: p.id , type_of_controller: "Stakeholder", sensitivity_of_post: sensitive_level_post, sensitivity_of_relationship:sensitive_level_between_stakeholder_and_owner ,allowed_aspects: allowed_aspects, diallowed_aspects: disallowed_aspects}
#           policies.push (policy)
#         end
#
#
#
#
#
#
#
#
#
#           #
#           # end
#           #
#           #   disallowed_aspects = Aspect.where(:user_id => p.id)
#           # disallowed_aspects.each do |x|
#           #   if
#           #
#           #   end
#           # end
#
#
#       def rt (stakeholderid,ownerid)
#         rtname=" "
#         aspects = Aspect.where(:user_id => stakeholderid.id)
#         aspects.each do |a|
#           checker = Privacy::Checker.new
#           members= checker.people_from_aspect_ids([a.id])
#           if members.include? (ownerid)
#             rtname= a.to_s
#           end
#         end
#         return rtname
#       end
#
#
#
#         end
#     end
#  #        # to determine the relation type between stakeholder and owner
#  #        def relationship_typ_between_owner_stakeholder(stakeholderid,ownerid)
#  #          rtname=" "
#  #          aspects = Aspect.where(:user_id => stakeholderid.id)
#  #          aspects.each do |a|
#  #            checker = Privacy::Checker.new
#  #            members= checker.people_from_aspect_ids([a.id])
#  #            if members.include? (ownerid)
#  #              rtname= a.to_s
#  #            end
#  #          end
#  #          return rtname
#  #        end
#  #
#  #    end
#  # end
#
#  # #/////////////////////
# #
# #   # protecting_loc.collect{|pp| pp.allowed_aspect}
# #
# # # def people_from_aspect_ids(aspect_ids)
# # #   contacts = []
# # #   aspect_ids.each do |a|
# # #     AspectMembership.where(:aspect_id =>  a).collect{|am| am.contact_id}.each do |c|
# # #       contacts.push(c)
# # #     end
# # #   end
# # #
# # #   people = []
# # #   contacts.each do |cid|
# # #     Contact.where(:id => cid).collect{|c| c.person_id}.each do |pid|
# # #       people.push(pid)
# # #     end
# # #   end
# # #   return people
# # # end
# # #
# # #   params[:status_message][:author].id
# # #   current_user.aspects_from_ids(destination_aspect_ids)
# # # # Query to the database checking if the wanted their location to be
# # # # protected from everyone
# # #   protecting_loc = PrivacyPolicy.where(:user_id => p.owner_id, :shareable_type => shareable)
# # #
# # #   return 0 if protecting_loc.blank?
# # #
# # #
# # #
# # # end