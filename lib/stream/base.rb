class Stream::Base
  TYPES_OF_POST_IN_STREAM = ['StatusMessage', 'Reshare']

  attr_accessor :max_time, :order, :user, :publisher

  def initialize(user, opts={})
    self.user = user
    self.max_time = opts[:max_time]
    self.order = opts[:order]
    self.publisher = Publisher.new(self.user, publisher_opts)
  end

  #requied to implement said stream
  def link(opts={})
    'change me in lib/base_stream.rb!'
  end

  # @return [Boolean]
  def can_comment?(post)
    return true if post.author.local?
    post_is_from_contact?(post)
  end

  def post_from_group(post)
    []
  end

  # @return [String]
  def title
    'a title'
  end

  # @return [ActiveRecord::Relation<Post>]
  def posts
    Post.scoped
  end

  # @return [Array<Post>]
  def stream_posts
    # Temporal array which will contain the posts which can be shown
    returningArray = Array.new
    # -------- Original code -------------
    self.posts.for_a_stream(max_time, order, self.user).tap do |posts|
      like_posts_for_stream!(posts) #some sql person could probably do this with joins.
      # -------- Original code -------------
      # We iterate over all to posts which tentatively will be posted
      posts.each do |p|

        # p << {reshareable: false}
        # p[:public] = false

        # filter based on algorithm 1 & 2& 3
        ppl= Diaspora::Mentionable.people_from_string(p.text)
        if (p.author_id == self.user.id) || (ppl.include?(self.user.id))
          permitted_mentioned_users_to_share= controllersharing(p)
          if permitted_mentioned_users_to_share.include?(self.user.id)
            p[:public] = true
           else
             p[:public] = false
          end
          returningArray.push(p)
        else
          permitted_users_to_viwe= permittedanddeniedaccessors(p)
          if permitted_users_to_viwe.include?(self.user.id)
            permitted_viwer_to_share = accessorsharing(p)
            if permitted_viwer_to_share.include?(self.user.id)
              p[:public] = true
            else
              p[:public] = false
            end
            returningArray.push(p)
          else
            puts "not adding this "
          end
        end

      end

        # ppl_owner_policy=ppl_owner_policy.map{|e| [e.owner_id]}.flatten(1)
        # if (p.author_id == self.user.id) || (ppl.include?(self.user.id))

        # # If the author of the post is not the user accessing the post we
        # # proceed to check if (s)he has access to all of them
        # if p.author_id != self.user.id
        #   # Since we are only protecting the user's location if the post does
        # #   # not contain a location can be shown
        #   if p.address == nil
        #     returningArray.push(p)
        #     # Otherwise we proceed to check
        #     end
        #   else
        #     # We get all the users mentioned in the post
        #     ppl = Diaspora::Mentionable.people_from_string(p.text)
        #     # We set a counter to 0
        #     count = 0
        #     # We iterate over all the mentioned users
        #     ppl.each do |person|
        #       # We check the privacy policy about the location of the user
        #       protecting_loc = PrivacyPolicy.where(:user_id => person.owner_id,
        #                                            :shareable_type => "Location")
        #       checker = Privacy::Checker.new
        #       people_disallowed = checker.people_from_aspect_ids(protecting_loc.collect{|pp| pp.allowed_aspect})
        #       # If we get any result it means that the users is protecting her
        #       # location. And (&&) also we check that the user requesting the
        #       # post is not the one mentioned
        #
        #       if people_disallowed.include?(self.user.person_id) && protecting_loc.first.hide
        #         # if (protecting_loc != nil) && (person.owner_id != self.user.id)
        #         # Therefore we increment th count
        #         count = count + 1
        #         # returningArray.push(pTemp)
        #       end
        #     end
        #     # Finally if there were no users protecting their location we add
        #     # the post to the posts to be shown
        #     if count == 0
        #       returningArray.push(p)
        #     else
        #       puts "Not adding the post"
        #     end
        #   end
        #   # If the author of the post is the one checking it we added to the
        #   # resulset since this user already knows the information.
        # else
        #   returningArray.push(p)
        # end
      end
    end
     returningArray
    end

  # Algorithm 1
   def permittedanddeniedaccessors (post)
    # Algorithm1 takes post as argument
    list_of_allowed_ids = []
    list_of_disallwoed_ids =[]
    final_list_of_permitted_accessors =[]
    final_list_of_denied_accessors =[]
    ppl= Diaspora::Mentionable.people_from_string(post.text)
    ppl=ppl.map{|e| [e.owner_id]}.flatten(1)
    ppl.push(post.author_id)

    policies=sharepolicies(post)
    policies.each do |controller|
      checker = Privacy::Checker.new
      # get allowed and disallowed users and delete ids of author and stakeholders form these lists
      if controller[:allowed_aspects] != nil
      permitted_accessors= checker.people_from_aspect_ids(controller[:allowed_aspects])
      ppl.each do |check_c_id|
        permitted_accessors.delete(check_c_id)  if permitted_accessors.include?(check_c_id)
      end
      end
      if controller[:disallowed_aspects] != nil
      denied_accessors= checker.people_from_aspect_ids(controller[:disallowed_aspects])
      ppl.each do |check_c_id|
        denied_accessors.delete(check_c_id) if denied_accessors.include?(check_c_id)
           #puts"hanaa"
           #if denied_accessors.include?(check_c_id)
           #denied_accessors=denied_accessors-check_c_id
           #end
      end
      end

    # interaction between allowed list and disallowed has to be empty
      denied_accessors= denied_accessors - permitted_accessors
      denied_accessors=denied_accessors.uniq
      permitted_accessors=permitted_accessors.uniq
      if permitted_accessors != []
        allowed_ids= Hash.new {|h,k| h[k]=[]}
        allowed_ids={controller[:user_id] => permitted_accessors}
        list_of_allowed_ids << allowed_ids
      end
      if denied_accessors != []
        disallowed_ids= Hash.new {|h,k| h[k]=[]}
        disallowed_ids={controller[:user_id] => denied_accessors}
        list_of_disallwoed_ids << disallowed_ids
      end
    end

    # check the conflicting
    decision_permit= 0.0
    list_of_allowed_ids.each do |controller_allowed_ids|
      controller_allowed_ids.each_value do |allowed_ids|
        allowed_ids.each do |user|
          denied_votes_ids=Array.new
          list_of_disallwoed_ids.each do |controller_disallowed_ids|
            v=controller_disallowed_ids.values.flatten(1)
            if v.include?(user)
              controllerid=controller_disallowed_ids.keys
              denied_votes_ids.push(controllerid[0])
              # denied_votes_ids=denied_votes_ids.flatten(1)
            end
          end

          denied_votes_ids=denied_votes_ids.uniq # I' not sure why this one for what ?
          if denied_votes_ids.none?
            final_list_of_permitted_accessors.push(user)
          else
            # compute deny decision
            decision_deny = 0.0
            denied_votes_ids.each do |controller_id|
            denied_decision_info=policies.detect {|x| x[:user_id] == controller_id}
              sensitivity_of_post= denied_decision_info[:sensitivity_of_post]
              sensitivity_of_relationship=denied_decision_info[:sensitivity_of_relationship]
              decision_deny += sensitivity_of_post * sensitivity_of_relationship
            end

            # compute permit decision
            permitted_votes_ids=[]
            list_of_allowed_ids.each do |controller_allowed_ids1|
              v=controller_allowed_ids1.values.flatten(1)
              if v.include?(user)
                controllerid= controller_allowed_ids1.keys
                permitted_votes_ids.push(controllerid[0])
                # permitted_votes_ids=permitted_votes_ids.flatten(1)
              end
            end
              permitted_votes_ids=permitted_votes_ids.uniq # I' not sure why this one for what ?
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
    end # end of conflicting case
    # add authoir and @stakeholders in final_list_of_permitted_accessors "no need for that since we post the post in owner and mention users regardless of algorithm result"
    # ppl.each do |id_associted_controller|
    #   final_list_of_permitted_accessors.push (id_associted_controller)
    # end
    return   final_list_of_permitted_accessors, final_list_of_denied_accessors #"here I only returen list of allowed users because if that user allowed than post will show up in his stream "
  end # end of algorithm


  # Algorithm 2
    def accessorsharing (post)
      final_list_of_disseminators= []
      final_list_of_non_disseminator= []
      permitted_controllers_votes_reshare= []
      denied_controllers_votes_reshare=[]
      contrller_cont=0
      reshare_permit_decision=0.0
      reshare_deny_decision=0.0
      final_list_of_permitted_accessors,final_list_of_denied_accessors = permittedAndDeniedAccessors(post)
      policies=sharepolicies(post)

      final_list_of_permitted_accessors.each do |viewer|
        policies.each do |controller|
          # infer how much controller trusts user
          relationship_type= rt1(controller[:user_id],viewer)
          relationship_type=relationship_type.to_s
          if relationship_type.nil? || relationship_type.empty?
          trust_level_between_controller_and_viewer=0.0
          else
            # retrieve trust level of this relationship type from controller side
            trust_level_between_controller_and_viewer= AspectsLevelsOfSenstivityAndTrust.where(:user_id => controller[:user_id], :relationship_type => relationship_type).collect{|e| e.trust_level}.first
            puts "hanaa"
          end
          # retrieve trust threshold of controller
          trust_threshold=Person.where(:owner_id => controller[:user_id]).collect{|am| am.tr_threshold}.first
          puts "hanaa"
           if trust_level_between_controller_and_viewer >= trust_threshold
             permitted_controllers_votes_reshare.push (controller[:user_id])
           else
             denied_controllers_votes_reshare.push(controller[:user_id])
           end
          contrller_cont=contrller_cont+1
        end
        if permitted_controllers_votes_reshare.size == contrller_cont
          final_list_of_disseminators.push(viewer)
        elsif denied_controllers_votes_reshare.size == contrller_cont
          final_list_of_non_disseminator.push(viewer)
        # the conflict case
        else
          permitted_controllers_votes_reshare.each do |controller_p|
                        permitted_decision_info=policies.find{|x| (x[:user_id] == controller_p)}
                        sensitivity_of_post= permitted_decision_info[:sensitivity_of_post]
                         reshare_permit_decision += sensitivity_of_post # where is sensitivity of relationship ?
          end
          denied_controllers_votes_reshare.each do |controller_d|
            denied_decision_info=policies.find{|x| (x[:user_id] == controller_d)}
            sensitivity_of_post= denied_decision_info[:sensitivity_of_post]
            reshare_deny_decision += sensitivity_of_post
          end
            if reshare_permit_decision >= reshare_deny_decision
              final_list_of_disseminators.push(viewer)
            else
              final_list_of_non_disseminator.push(viewer)
            end
        end
      end
      return final_list_of_disseminators
    end

  # Algorithm 3 takes policies and controllers sharing voting
    def controllersharing(post)
      permitted_controllers_to_reshare=[]
      denied_controllers_to_reshare=[]
      vote_permit=[]
      vote_deny=[]
      permitted_decision=0
      denied_decision=0
      vote=0

      controllers= Diaspora::Mentionable.people_from_string(post.text)
      controllers=controllers.map{|e| [e.owner_id]}.flatten(1)
      controllers.push(post.author_id)

      controllers.each do |cid|

       rest_of_controllers=controllers-[cid]
       # retrieve votes of cid
        rest_of_controllers.each do |voter|
          # which kind of relation looking for from where to where ?? it is the type of relationship cid has in voter social network
          relationship_type= rt1(voter,cid)
          relationship_type=relationship_type.to_s
          if relationship_type.nil? || relationship_type.empty?
            vote=0
          else
            id_of_aspect = Aspect.where(:user_id => voter, :name => relationship_type ).select(:id)
            allwoed_aspects_ids_to_reshare= ControllersResharingVoting.where(:user_id => voter).collect{|e| e.allowed_aspects_ids}

            if allwoed_aspects_ids_to_reshare.include? (id_of_aspect) ||  allwoed_aspects_ids_to_reshare.include? (-3) || allwoed_aspects_ids_to_reshare.include?(-1)
                 vote_permit.push(voter)
            else
               vote_deny.push(voter)
            end

          end

          end

        if rest_of_controllers.size == vote_permit.size
          permitted_controllers_to_reshare.push(cid)

        elsif rest_of_controllers.size == vote_deny.size
          denied_controllers_to_reshare.push(cid)

        else # the conflict case
          vote_permit.each do |voter_p|
            trv=voter_trust_level(voter_p,controllers)
            permitted_decision += trv
          end
          vote_deny.each do |voter_d|
            trv=voter_trust_level(voter_d,controllers)
            denied_decision += trv
          end
        end

      if permitted_decision >= denied_decision
        permitted_controllers_to_reshare.push(cid)
      else
        denied_controllers_to_reshare.push(cid)
      end
   end
   return permitted_controllers_to_reshare
end


    def sharepolicies(p)
  policies =[ ]

  # -------- Gathering sharing policies for all associated controllers------
  # ------- stakeholders policies ---------

  # Getting the mentioned people in the post
  ppl= Diaspora::Mentionable.people_from_string(p.text)
  # ppl=ppl.map{|e|[e.owner_id]}.flatten(1)
  # if ppl!=nil
  ppl.each do |person|
    # retrieve relationship type between stakeholder and owner
    x=person.owner_id
    y=p.author_id
    relationship_type= rt(x,y)
    relationship_type=relationship_type.to_s
    # retrieve sensitive level of this relationship type from stakeholder side
    # sensitive_level_between_stakeholder_and_owner= Aspect.where(:user_id => person.owner_id, :name => relationship_type).collect{|e| e.sensitive_level}.first
     sensitive_level_between_stakeholder_and_owner=AspectsLevelsOfSenstivityAndTrust.where(:user_id => person.owner_id,:relationship_type => relationship_type).collect{|e| e.sensitive_level}.first
    # retrieve sensitive level of post
    #if post has 2 or 3 of these items then we consider the higher sl_post
    sensitive_levels_post= Array.new
    sensitive_level_post = 0.0

    if p.address.present? then
      sensitive_level_post_location = PostsSensitiveLevels.where(:user_id => person.owner_id, :post_type=>"location").collect{|am| am.sensitive_level}.first
      sensitive_levels_post.push(sensitive_level_post_location)
    end
    if p.photos.present? then
      sensitive_level_post_photos = PostsSensitiveLevels.where(:user_id => person.owner_id, :post_type=>"picture").collect{|am| am.sensitive_level}.first
      sensitive_levels_post.push(sensitive_level_post_photos)
    end
    if ppl.length > 1 then # post has another mentioned users (more than 1)
      sensitive_level_post_metions = PostsSensitiveLevels.where(:user_id => person.owner_id, :post_type=>"mention").collect{|am| am.sensitive_level}.first
      sensitive_levels_post.push (sensitive_level_post_metions)
    end

    if sensitive_levels_post.length == 0 # "*" here when post doesn't contain (address,pic or another @user) will consider minimum level for sensitivity
       sensitive_level_post = 0.01
    elsif sensitive_levels_post.length >= 1
      sensitive_level_post = sensitive_levels_post.max
    end

    # determine allowed aspects
    # user_aspects=Aspect.where(:user_id => person.owner_id).select(:id)
    # user_aspects= user_aspects.map{|e| [e.id]}
    # user_aspects= user_aspects.flatten(1)
    user_aspects_ids = Aspect.where(:user_id => person.owner_id).collect{|e| e.id}
    disallowed_aspects=[ ]

    if  relationship_type == "Family"
      allowed_aspects= AllowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Family").collect{|e| e.allowed_aspectids}

    elsif relationship_type == "Friends"
      allowed_aspects= AllowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Friends").collect{|e| e.allowed_aspectids}

    elsif relationship_type == "Work"
      allowed_aspects= AllowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Work").collect{|e| e.allowed_aspectids}

    elsif relationship_type == "Acquaintances"
      allowed_aspects= AllowedAspects.where(:user_id => person.owner_id.id,:relationship_type =>"Acquaintances").collect{|e| e.allowed_aspectids}
    end
    # when controller allows everyone (this not mean public , it means only aspects in person SN )
    if allowed_aspects.include? -1
      user_aspects_ids.each do |aspects_id|
        allowed_aspects.push(aspects_id)
      end
    # when controller doesn't allow anybody
    elsif allowed_aspects.include? -2
      # make the default of disallowed in this case as following (no one from person SN and no one from all associated controllers SNs )
      # this will overwriting if person change something else form disallwoed check_list
      ppl= Diaspora::Mentionable.people_from_string(p.text)
      ppl.push(p.author_id)
      ppl.each do |controller|
        controller_aspects_ids = Aspect.where(:user_id => controller.owner_id).collect{|e| e.id}
        controller_aspects_ids.each do |aspects_id|
          disallowed_aspects.push(aspects_id)
        end
      end
      allowed_aspects= nil
    # when controller doesn't care at all that means he/she doesn't participate in collaborative process and disllowed will be nil as well as default option
      # this will overwriting if person change something else form disallwoed check_list
    elsif allowed_aspects.include? -3
        allowed_aspects = nil
        disallowed_aspects = nil
    end

    # determined disallowed aspects and users for each controller (person) 4 cases
    if  relationship_type == "Family"
      disallowed_aspects= DisallowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Family").collect{|e| e.disallowed_aspectids}

    elsif relationship_type == "Friends"
      disallowed_aspects= DisallowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Friends").collect{|e| e.disallowed_aspectids}

    elsif relationship_type == "Work"
      disallowed_aspects= DisallowedAspects.where(:user_id => person.owner_id,:relationship_type =>"Work").collect{|e| e.disallowed_aspectids}

    elsif relationship_type == "Acquaintances"
      disallowed_aspects= DisallowedAspects.where(:user_id => person.owner_id.id,:relationship_type =>"Acquaintances").collect{|e| e.disallowed_aspectids}
    end
    # 1.when controller doesn't care that means his disallowed list is nil
    # if he/she doesn't care who allowed as well then this controller has allowed_aspects = nil disallowed_aspects= nil thus s/he will not participate in collaborative process
    if disallowed_aspects.include? -3
    disallowed_aspects = nil
    # 2. everyone is not belong to person aspects list
    elsif disallowed_aspects.include? -4
    ppl= Diaspora::Mentionable.people_from_string(p.text)
      ppl.push(p.author_id)
      ppl.delete(person)
      ppl.each do |controller|
        controller_aspects_ids = Aspect.where(:user_id => controller.owner_id).collect{|e| e.id}
        controller_aspects_ids.each do |aspects_id|
          disallowed_aspects.push(aspects_id)
        end
      end
    # 3. aspects haven't been selected as allowed aspects from my aspects list
      # determine disallowed aspects according to selected allowed aspects
    elsif disallowed_aspects.include? -5
    # user_aspects_ids.length != allowed_aspects.length
        user_aspects_ids.each do |dis|
          if allowed_aspects.exclude? (dis)
            disallowed_aspects.push(dis)
          end
        end
    #4. every aspects form my aspects list that haven't been selected and all users who isn't member in anyone of my aspects
    elsif disallowed_aspects.include? -6
      # first part which set aspects that didn't select as allowed to be disallowed
      user_aspects_ids.each do |dis|
        if allowed_aspects.exclude? (dis)
          disallowed_aspects.push(dis)
        end
      end
     # second part which set all controllers' aspects as disallowed aspects
      ppl= Diaspora::Mentionable.people_from_string(p.text)
      ppl.push(p.author_id)
      ppl.delete(person)
      ppl.each do |controller|
        controller_aspects_ids = Aspect.where(:user_id => controller.owner_id).collect{|e| e.id}
        controller_aspects_ids.each do |aspects_id|
          disallowed_aspects.push(aspects_id)
        end
      end
    end


    policy= {user_id: person.owner_id , type_of_controller: "Stakeholder",  sensitivity_of_relationship: sensitive_level_between_stakeholder_and_owner,sensitivity_of_post: sensitive_level_post,allowed_aspects: allowed_aspects, disallowed_aspects: disallowed_aspects}
    policies.push (policy)
  end # for stakeholders loop

    # ------owner's policy---------

      # determined allowed and disallowed aspects
      disallowed_aspects=[ ]
      owner_all_aspects= Aspect.where(:user_id => p.author_id).collect{|e| e.id}
      allowed_aspects = p.aspect_ids
      # (params[:status_message][:aspect_ids]).map(&:to_i)
      if (p.public == true) || (owner_all_aspects.length == allowed_aspects.length)
        # params[:status_message][:aspect_ids].include?('public') || params[:status_message][:aspect_ids].include?('all_aspects') || owner_all_aspects.length == allowed_aspects.length
        allowed_aspects = p.aspect_ids
        disallowed_aspects=nil
      elsif owner_all_aspects.length != allowed_aspects.length
        owner_all_aspects.each do |dis|
          if allowed_aspects.exclude? (dis)
            disallowed_aspects.push(dis)
          end
        end
      end

      # determined sensitive level of relationship type
      ppl= Diaspora::Mentionable.people_from_string(p.text)
      sensitive_level_between_owner_and_all_stakeholders=[]
      ppl.each do |person|
        # retrieve relationship type between owner and each stakeholders
        x=p.author_id
        y=person.owner_id
        relationship_type= rt(x, y)
        relationship_type=relationship_type.to_s
        # retrieve sensitive level of this relationship type from owner side
        # sensitive_level_between_owner_and_stakeholder= Aspect.where(:user_id => p.author_id, :name => relationship_type).collect{|e| e.sensitive_level}.first
        sensitive_level_between_owner_and_stakeholder= AspectsLevelsOfSenstivityAndTrust.where(:user_id => p.author_id,:relationship_type => relationship_type).collect{|e| e.sensitive_level}.first
        sensitive_level_between_owner_and_all_stakeholders.push(sensitive_level_between_owner_and_stakeholder)
      end
      sensitive_level_of_relationship_type= sensitive_level_between_owner_and_all_stakeholders.max

      # determined sensitive level of shared item
      sensitive_levels_post= []
      if p.address.present? then
        sensitive_level_post_location = PostsSensitiveLevels.where(:user_id => p.author_id, :post_type=>"location").collect{|am| am.sensitive_level}.first
        sensitive_levels_post.push(sensitive_level_post_location)
      end
      if p.photos.present? then
        sensitive_level_post_photos = PostsSensitiveLevels.where(:user_id => p.author_id,:post_type=>"picture").collect{|am| am.sensitive_level}.first
        sensitive_levels_post.push(sensitive_level_post_photos)
      end
      if ppl.length >= 1 then
        sensitive_level_post_metions = PostsSensitiveLevels.where(:user_id =>p.author_id,:post_type=>"mention").collect{|am| am.sensitive_level}.first
        sensitive_levels_post.push(sensitive_level_post_metions)
      end
      sensitive_level_post_owner=sensitive_levels_post.max

    policy= {user_id: p.author_id, type_of_controller: 'Owner',sensitivity_of_relationship: sensitive_level_of_relationship_type,sensitivity_of_post: sensitive_level_post_owner,allowed_aspects:allowed_aspects, disallowed_aspects:disallowed_aspects}
    policies.push(policy)

  return policies

end

    def rt (u1,u2)
    rtname=" "
    aspects = Aspect.where(:user_id => u1)
    aspects.each do |a|
      checker = Privacy::Checker.new
      members= checker.people_from_aspect_ids([a.id])
      if members.include? (u2)
        rtname= a.to_s
      end
    end
    return rtname
  end

    def rt1 (u1,u2)
    rtname=""
    aspects = Aspect.where(:user_id => u1)
    aspects.each do |a|
      checker = Privacy::Checker.new
      members= checker.people_from_aspect_ids([a.id])
      if members.include? (u2)
        rtname= a.to_s
      end
    end
    return rtname
  end

    def voter_trust_level (u1,controllers_v)
    controllersvvvv=controllers_v-[u1]
    voter_tt=0
    controllersvvvv.each do |id|
      relationship_type= rt1(u1,id)
      relationship_type=relationship_type.to_s
      if relationship_type.nil? || relationship_type.empty?
        trust_level=0
        # retrieve trust level of this relationship type from controller side
      else
          trust_level= AspectsLevelsOfSenstivityAndTrust.where(:user_id => id, :relationship_type => relationship_type).collect{|e| e.trust_level}.first
      end
      voter_tt += trust_level
    end
    return voter_tt
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    people_ids = self.stream_posts.map{|x| x.author_id}
    Person.where(:id => people_ids).
        includes(:profile)
  end

  # @return [String] def contacts_title 'change me in lib/base_stream.rb!'
  def contacts_title
    'change me in lib/base_stream.rb!'
  end

  # @return [String]
  def contacts_link
    Rails.application.routes.url_helpers.contacts_path
  end

  # @return [Boolean]
  def for_all_aspects?
    true
  end

  #NOTE: MBS bad bad methods the fact we need these means our views are foobared. please kill them and make them
  #private methods on the streams that need them
  def aspects
    user.aspects
  end

  # @return [Aspect] The first aspect in #aspects
  def aspect
    aspects.first
  end

  def aspect_ids
    aspects.map{|x| x.id}
  end

  def max_time=(time_string)
    @max_time = Time.at(time_string.to_i) unless time_string.blank?
    @max_time ||= (Time.now + 1)
  end

  def order=(order_string)
    @order = order_string
    @order ||= 'created_at'
  end

  protected
  # @return [void]
  def like_posts_for_stream!(posts)
    return posts unless @user

    likes = Like.where(:author_id => @user.person_id, :target_id => posts.map(&:id), :target_type => "Post")

    like_hash = likes.inject({}) do |hash, like|
      hash[like.target_id] = like
      hash
    end

    posts.each do |post|
      post.user_like = like_hash[post.id]
    end
  end

  # @return [Hash]
  def publisher_opts
    {}
  end

  # Memoizes all Contacts present in the Stream
  #
  # @return [Array<Contact>]
  def contacts_in_stream
    @contacts_in_stream ||= Contact.where(:user_id => user.id, :person_id => people.map{|x| x.id}).all
  end

  # @param post [Post]
  # @return [Boolean]
  def post_is_from_contact?(post)
    @can_comment_cache ||= {}
    @can_comment_cache[post.id] ||= contacts_in_stream.find{|contact| contact.person_id == post.author.id}.present?
    @can_comment_cache[post.id] ||= (user.person_id == post.author_id)
    @can_comment_cache[post.id]
  end
end
