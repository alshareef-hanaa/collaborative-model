module Privacy
  class Checker



    # I don't need params but post
    def permittedAndDeniedAccessors (post)
       # Algorithm1 takes policies as argument
       list_of_allowed_ids = []
       list_of_disallwoed_ids =[]
       final_list_of_permitted_accessors =[]
       final_list_of_denied_accessors =[]
       ppl= Diaspora::Mentionable.people_from_string(post.text)
       ppl.push(post.author_id)
       # policy= {user_id: p.id , type_of_controller: "Stakeholder", sensitivity_of_post: sensitive_level_post, sensitivity_of_relationship: sensitive_level_between_stakeholder_and_owner ,allowed_aspects: allowed_aspects, disallowed_aspects: disallowed_aspects}
       # policy= {user_id: params[:status_message][:author].id, type_of_controller: 'Owner', sensitivity_of_post: sensitive_level_post_owner, sensitivity_of_relationship: sensitive_level_of_relationship_type,allowed_aspects:allowed_aspects, disallowed_aspects:disallowed_aspects}

       policies=checkSharingPolicies(post)
       # accessors = {}
        policies.each do |controller|
          # checker = Privacy::Checker.new don't need that
          # get allowed and disallowed users and delete ids of author and stakeholders form these lists
          permitted_accessors= people_from_aspect_ids(controller[:allowed_aspects])
          permitted_accessors=permitted_accessors-ppl
          denied_accessors= people_from_aspect_ids(controller[:disallowed_aspects])
          denied_accessors=denied_accessors-ppl
          allowed_ids= Hash.new {|h,k| h[k]=[]}
          allowed_ids={controller[:user_id] => permitted_accessors}
          list_of_allowed_ids << allowed_ids
          disallowed_ids= Hash.new {|h,k| h[k]=[]}
          disallowed_ids={controller[:user_id] => denied_accessors}
          list_of_disallwoed_ids << disallowed_ids
        end
        # check the confliction
         decision_permit= 0.0
         decision_deny= 0.0
         list_of_allowed_ids.each do |controller_allowed_ids|
           controller_allowed_ids.each_value do |allowed_ids|
             allowed_ids.each do |user|
               denied_votes_ids=[]
               list_of_disallwoed_ids.each do |controller_disallowed_ids|
                 v=controller_disallowed_ids.values.flatten(1)
                if v.include?(user)
                  controllerid=controller_disallowed_ids.keys
                  denied_votes_ids.push(controllerid[0])
                  # denied_votes_ids=denied_votes_ids.flatten(1)
                end
             end

               if denied_votes_ids.none?
                  final_list_of_permitted_accessors.push(user)
               else
                 # compute deny decision
                 denied_votes_ids.each do |controller_id|
                 denied_decision_info=policies.find{|x| (x[:user_id] == controller_id)}
                 sensitivity_of_post= denied_decision_info[:sensitivity_of_post]
                 sensitivity_of_relationship=denied_decision_info[:sensitivity_of_relationship]
                 decision_deny += sensitivity_of_post * sensitivity_of_relationship
               end

                 #compute permit decision
                 permitted_votes_ids=[]
                 list_of_allowed_ids.each do |controller_allowed_ids1|
                   v=controller_allowed_ids1.values.flatten(1)
                   if v.include?(user)
                    controllerid= controller_allowed_ids1.keys
                    permitted_votes_ids.push(controllerid[0])
                    # permitted_votes_ids=permitted_votes_ids.flatten(1)
                   end
                 end

                  permitted_votes_ids.each do |controller_id|
                  permitted_decision_info=policies.find{|x| (x[:user_id] == controller_id)}
                  sensitivity_of_post= permitted_decision_info[:sensitivity_of_post]
                  sensitivity_of_relationship=permitted_decision_info[:sensitivity_of_relationship]
                  decision_permit += sensitivity_of_post * sensitivity_of_relationship
                  end

                if decision_permit >= decision_deny
                 final_list_of_permitted_accessors.push(user)
                else
                 final_list_of_denied_accessors.push(user)
                end
                  # remove that user from lists
                  # list_of_allowed_ids.delete_if{|_,v| v== user}
                  # list_of_disallwoed_ids.delete_if{|_,v| v == user}
               end
               # remove that user from lists
             end
           end
         end
      # add authoir and @stakeholders in final_list_of_permitted_accessors
       ppl.each do |id_associted_controller|
         final_list_of_permitted_accessors.push (id_associted_controller)
       end
     return final_list_of_denied_accessors, final_list_of_permitted_accessors
    end
    # CALL in Algorithm 1 TO GET POLICIES OF SPECIFIC POST SO IT TAKES POST AS PARMETER
    def checkSharingPolicies (post)

      # ----------- Adedd by Hanaa ----------
      # -------- Gathering sharing policies for all associated controllers------

      policies =[ ]
      # Getting the mentioned people in the post
      ppl= Diaspora::Mentionable.people_from_string(post.text)

      ppl.each do |p|
        # retrieve relationship type between stakeholder and owner
        relationship_type= rt(p,post.author_id)
        relationship_type=relationship_type.to_s
        # retrieve sensitive level of this relationship type from stakeholder side
        sensitive_level_between_stakeholder_and_owner= Aspect.where(:user_id => p.id, :name => relationship_type).collect{|e| e.sensitive_level}.first

        # retrieve sensitive level of post
        #if post has 2 or 3 of these items then we consider the higher sl_post to use
        sensitive_levels_post= []
        if post.address != nil  # or can be p.address !=nil
          sensitive_level_post_location = PostsSensitiveLevels.where(:user_id => p.id, :post_type=>"location").collect{|am| am.sensitive_level}.first
          sensitive_levels_post.push (sensitive_level_post_location)
        end

        if post.photos.present? then
          sensitive_level_post_photos = PostsSensitiveLevels.where(:user_id => p.id, :post_type=>"picture").collect{|am| am.sensitive_level}.first
          sensitive_levels_post.push (sensitive_level_post_photos)
        end

        if ppl.length > 1 then # here we think about if author has includ bout this or not .. I think it has
          sensitive_level_post_metions = PostsSensitiveLevels.where(:user_id => p.id, :post_type=>"mention").collect{|am| am.sensitive_level}.first
          sensitive_levels_post.push (sensitive_level_post_metions)
        end
        sensitive_level_post=sensitive_levels_post.max

        # determine allowed aspects and disallowed
        user_aspects=Aspect.where(:user_id => p.id).select(:id)
        user_aspects= user_aspects.map{|e| [e.id]}
        user_aspects= user_aspects.flatten(1)
        user_aspects_ids = Aspect.where(:user_id => p.id).collect{|e| e.id}
        disallowed_aspects=[ ]


        if  relationship_type == "Family"
          allowed_aspects= AllowedAspects.where(:user_id => p.id,:relationship_type =>"Family").collect{|e| e.allowed_aspectids}

        elsif relationship_type == "Friends"
          allowed_aspects= AllowedAspects.where(:user_id => p.id,:relationship_type =>"Friends").collect{|e| e.allowed_aspectids}

        elsif relationship_type == "Work"
          allowed_aspects= AllowedAspects.where(:user_id => p.id,:relationship_type =>"Work").collect{|e| e.allowed_aspectids}

        elsif relationship_type == "Acquaintances"
          allowed_aspects= AllowedAspects.where(:user_id => p.id,:relationship_type =>"Acquaintances").collect{|e| e.allowed_aspectids}
        end
        # when controller allows everyone (this not mean public)
        if allowed_aspects.include? -1
          user_aspects_ids.each do |aspects_id|
            allowed_aspects.push(aspects_id)
          end
          disallowed_aspects= nil
          # when controller dosen't allow anybody
        elsif allowed_aspects.include? -2
          user_aspects_ids.each do |aspects_id|
            disallowed_aspects.push(aspects_id)
          end
          allowed_aspects= nil
          # determine disallowed aspects according to selected allowed aspects
        elsif user_aspects_ids.length != allowed_aspects.length
          user_aspects_ids.each do |dis|
            if allowed_aspects.exclude? (dis)
              disallowed_aspects.push(dis)
            end
          end
        end
        # set policy of the stakeholder with id p
        # when controller dosen't care which means our allowed and disallowed aspects
        # in policy are nil then this associated controller is not involved in the collaborative decision
        if allowed_aspects.exclude? -3
          policy= {user_id: p.id , type_of_controller: "Stakeholder", sensitivity_of_post: sensitive_level_post, sensitivity_of_relationship: sensitive_level_between_stakeholder_and_owner ,allowed_aspects: allowed_aspects, disallowed_aspects: disallowed_aspects}
          policies.push (policy)
        end

      end

      # ------owner's policy---------

      # determined allowed and disallowed aspects
      disallowed_aspects=[ ]
      owner_all_aspects= Aspect.where(:user_id => post.author_id).collect{|e| e.id}
      allowed_aspects = post.aspect_ids
                     # (params[:status_message][:aspect_ids]).map(&:to_i)
      if (post.public == true) || (owner_all_aspects.length == allowed_aspects.length)
      # params[:status_message][:aspect_ids].include?('public') || params[:status_message][:aspect_ids].include?('all_aspects') || owner_all_aspects.length == allowed_aspects.length
        owner_all_aspects.each do |aspects_id|
          allowed_aspects.push(aspects_id)
        end
        disallowed_aspects=nil
      elsif owner_all_aspects.length != allowed_aspects.length
        owner_all_aspects.each do |dis|
          if allowed_aspects.exclude? (dis)
            disallowed_aspects.push(dis)
          end
        end
      end
      # determined sensitive level of relationship type
      ppl_owner_policy= Diaspora::Mentionable.people_from_string(post.text)
      sensitive_level_between_owner_and_all_stakeholders=[]
      ppl_owner_policy.each do |p|
        # retrieve relationship type between owner and each stakeholders
        relationship_type= rt(post.author_id,p)
        relationship_type=relationship_type.to_s
        # retrieve sensitive level of this relationship type from owner side
        sensitive_level_between_owner_and_stakeholder= Aspect.where(:user_id => post.author_id, :name => relationship_type).collect{|e| e.sensitive_level}.first
        sensitive_level_between_owner_and_all_stakeholders.push (sensitive_level_between_owner_and_stakeholder)
      end
      sensitive_level_of_relationship_type= sensitive_level_between_owner_and_all_stakeholders.max
      # determined sensitive level of shared item
      sensitive_levels_post= []
      if params[:location_address].present?
        sensitive_level_post_location = PostsSensitiveLevels.where(:user_id => params[:status_message][:author].id, :post_type=>"location").collect{|am| am.sensitive_level}.first
        ensitive_levels_post.push (sensitive_level_post_location)
      end
      if params[:photos].present?
        sensitive_level_post_photos = PostsSensitiveLevels.where(:user_id => params[:status_message][:author].id,:post_type=>"picture").collect{|am| am.sensitive_level}.first
        sensitive_levels_post.push (sensitive_level_post_photos)
      end
      if ppl.length > 1 then
        sensitive_level_post_metions = PostsSensitiveLevels.where(:user_id =>params[:status_message][:author].id,:post_type=>"mention").collect{|am| am.sensitive_level}.first
        sensitive_levels_post.push (sensitive_level_post_metions)
      end
      sensitive_level_post_owner=sensitive_levels_post.max

      policy= {user_id: params[:status_message][:author].id, type_of_controller: 'Owner', sensitivity_of_post: sensitive_level_post_owner, sensitivity_of_relationship: sensitive_level_of_relationship_type,allowed_aspects:allowed_aspects, disallowed_aspects:disallowed_aspects}
      policies.push (policy)
     return policies
    end
    def checkPolicies(params)
       # ------- Added by Raul ---------

        # Initially no policies are violated
        count_of_violated_policies = 0

      puts "---Checking the privacy policies---"

      # Check whether any mention policy has been violated
      # count_of_violated_policies = checkMentionPolicy(params)
      count_of_violated_policies = checkShareable(params, "Mentions")
      puts "Mention policies violated: " + count_of_violated_policies.to_s
      # If not, then check for violations of Location policies
      if count_of_violated_policies == 0 && params[:location_address].present?
        # count_of_violated_policies = checkLocationPolicy(params)
        count_of_violated_policies = checkShareable(params, "Location")
        puts "Location policies violated: " + count_of_violated_policies.to_s
      end

      if count_of_violated_policies == 0 && params[:photos].present?
        # count_of_violated_policies = checkLocationPolicy(params)
        count_of_violated_policies = checkShareable(params, "Pictures")
        puts "Pictures policies violated: " + count_of_violated_policies.to_s
      end

      return count_of_violated_policies
    end

    def checkShareable(params, shareable)
      # Getting the people mentioned in the post
      ppl = Diaspora::Mentionable.people_from_string(params[:status_message][:text])

      # Temporal variables for accounting the people who have a privacy policy
      # violated
      violatedPeopleCount = 0

      # Loop through all the mentioned people
      ppl.each do |p|
        # Query to the database checking if the wanted their location to be
        # protected from everyone
        protecting_loc = PrivacyPolicy.where(:user_id => p.owner_id, :shareable_type => shareable)

        return 0 if protecting_loc.blank?
        # If we get a row, it means that the policy is going to be violated
        # since they are mentioned in a status message containing a location
        puts params[:status_message][:aspect_ids] && protecting_loc.first.block
        if protecting_loc.collect { |pl| pl.allowed_aspect }.include? -1
          violatedPeopleCount = violatedPeopleCount + 1
        elsif (params[:status_message][:aspect_ids].include?('public') || params[:status_message][:aspect_ids].include?('all_aspects')) && protecting_loc.first.block
          violatedPeopleCount = violatedPeopleCount + 1
        else
          # Otherwise we need to check the aspects which are allowed and nobody outside this audience is included in the post audience

          # We get the ids of the people to whom the post is going to be shared
          people_to_share = people_from_aspect_ids(params[:status_message][:aspect_ids])
          # We add also the author's person id since, this user will obviously know the post
          people_to_share.push(params[:status_message][:author].id)
          puts "People to share"
          puts people_to_share

          # We get the ids of the people that the mentioned user allows
          location_pp_user = PrivacyPolicy.where(:user_id => p.owner_id, :shareable_type => shareable)
          people_disallowed = people_from_aspect_ids(location_pp_user.collect{|pp| pp.allowed_aspect})
          # We add the mentioned person as part of the allowed people
          # people_allowed.push(p.id)
          puts "Disallowed people"
          puts people_disallowed


          # Subtract the people to share minus the people allowed
          # people_result = people_to_share - people_allowed
          disallowed_people_count = 0
          people_to_share.each do |pts|
            if people_disallowed.include? pts
              disallowed_people_count = disallowed_people_count + 1
            end
          end

          # If the result is greater than 0, there are people in the audience that are not allowed to see the post
          # therefore, if the block flag is activated we block the posting
          # violatedPeopleCount = violatedPeopleCount + 1 if (people_result.count > 0 && location_pp_user.first.block)
          violatedPeopleCount = violatedPeopleCount + 1 if (disallowed_people_count > 0 && location_pp_user.first.block)
        end
      end # each do loop
      return violatedPeopleCount
    end

    def send_to_larva(uid,event)
      Thread.new{
        sock = TCPSocket.new('localhost',7)
        message = "diaspora;" + uid.to_s + ";"+event+"\n"
        sock.write(message)
        sock.close_write
        response = sock.gets
        puts("[LARVA - REPONSE] message: " + response)
        handl = Privacy::Handler.new
        if response.include? "disable-posting"
          handl.add_policy(uid,"Location","yes","no")
          puts "Blocking mentions for user " + uid.to_s
        end
        if response.include? "enable-posting"
          #Structure of the message '<user_id>;<action>'
          values = response.split(";")
          uid = values.at(0).to_i
          handl.delete_policy("Location",uid)
          puts "Enabling mentions for user " + uid.to_s
        end
        sock.close
      }
    end # send_to_larva function

    def send_to_larva(uid,event,shareable,aspect)
      Thread.new{
        sock = TCPSocket.new('localhost',7)
        message = "diaspora;" + uid.to_s + ";"+event+"\n"
        sock.write(message)
        sock.close_write
        response = sock.gets
        puts("[LARVA - REPONSE] message: " + response)
        handl = Privacy::Handler.new
        handl.reset_policies(shareable,uid)
        if response.include? "disable-posting"
          if aspect == -1
            handl.add_policy(uid,shareable,"yes","no",-1)
          else
            # puts "Entering..."
            # aspects = handl.get_user_aspect_ids(uid)
            # puts "Aspects"
            # puts aspects
            # temp = []
            # temp.push(aspect)
            # allowed_aspects = aspects - temp
            # puts "Allowed aspects"
            # puts allowed_aspects
            # allowed_aspects.each do |aa|
              handl.add_policy(uid,shareable,"yes","no",aspect)
            # end
          end
          puts "Blocking mentions for user " + uid.to_s
        end
        if response.include? "enable-posting"
          #Structure of the message '<user_id>;<action>'
          values = response.split(";")
          uid = values.at(0).to_i
          # handl.delete_policy(shareable,uid)
          handl.reset_policies(shareable,uid)
          puts "Enabling mentions for user " + uid.to_s
        end
        sock.close
      }
    end # send_to_larva function

    # @param An array with aspect ids
    # @return An array with the people ids of from the aspects ids
    def people_from_aspect_ids(aspect_ids)
      contacts = []
      aspect_ids.each do |a|
        AspectMembership.where(:aspect_id =>  a).collect{|am| am.contact_id}.each do |c|
          contacts.push(c)
        end
      end

      people = []
      contacts.each do |cid|
        Contact.where(:id => cid).collect{|c| c.person_id}.each do |pid|
          people.push(pid)
        end
      end
      return people
    end

    def rt (u1,u2)
      rtname=""
      aspects = Aspect.where(:user_id => u1.id)
      aspects.each do |a|
        checker = Privacy::Checker.new
        members= checker.people_from_aspect_ids([a.id])
        if members.include? (u2)
          rtname= a.to_s
        end
      end
      return rtname
    end
  end # Checker class
end # Privacy module
