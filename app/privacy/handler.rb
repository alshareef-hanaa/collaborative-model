module Privacy
  class Handler
    def add_policy(uid, shareable, to_block, to_hide)
      return_message = ""
      policyTemp = PrivacyPolicy.where(:user_id => uid,
                                     :shareable_type => shareable).first
      if policyTemp != nil
        return_message = "Diaspora is already protecting your " + shareable
      else
        policy = PrivacyPolicy.new(:user_id => uid,
                                   :shareable_type => shareable,
                                   :block => to_block == "yes" ? 1 : 0, # Take the input from the user
                                   :hide => to_hide == "yes" ? 1 : 0, # Take the input from the user
                                   :allowed_aspect => nil) # Take the input from the user
        policy.save
        return_message = "Diaspora is protecting your " + shareable
      end
      return return_message
    end

    def add_policy(uid, shareable, to_block, to_hide, aspect)
      return_message = ""

      policy = PrivacyPolicy.new(:user_id => uid,
                                 :shareable_type => shareable,
                                 :block => to_block == "yes" ? 1 : 0, # Take the input from the user
                                 :hide => to_hide == "yes" ? 1 : 0, # Take the input from the user
                                 :allowed_aspect => aspect) # Take the input from the user
      policy.save
      # return_message = "Diaspora is protecting your " + shareable
      return return_message
    end

    def delete_policy(shareable, uid)
      policy = PrivacyPolicy.where(:user_id => uid,
                                  :shareable_type => shareable).first
      policy.destroy if policy != nil
      return "Diaspora is **NOT** protecting your " + shareable
    end

    def reset_policies(shareable, uid)
      PrivacyPolicy.where(:user_id => uid,
                          :shareable_type => shareable).find_each do |policy|
        policy.destroy
      end
    end

    def get_user_aspect_ids(uid)
      aspects_temp = Aspect.where(:user_id => uid)
      aspects = []
      aspects_temp.each do |a|
        aspects = aspects.push(a.id)
      end
      return aspects
    end

    # def get_user_disallowed_aspects(uid, shareable)
    #   location_privacy_policies = PrivacyPolicy.where(:user_id => uid,
    #                                                   :shareable_type => shareable)
    #   if location_privacy_policies.collect{|pp| pp.allowed_aspect}.include? -1
    #     return [-1]
    #   else
    #     aspects = get_user_aspect_ids(uid)
    #     return aspects.collect{|a| a if !location_privacy_policies.collect{|pp| pp.allowed_aspect}.include? a}
    #   end
    # end
    def get_user_disallowed_aspects(uid, shareable)
      location_privacy_policies = PrivacyPolicy.where(:user_id => uid,
                                                      :shareable_type => shareable)
      if location_privacy_policies.collect{|pp| pp.allowed_aspect}.include? -1
        return [-1]
      else
        # aspects = get_user_aspect_ids(uid)
        return location_privacy_policies.collect{|pp| pp.allowed_aspect}
      end
    end

    # ---------- Added by Hanaa ----------
      # policies for allowed aspects

      def add_policies(uid, relation_type, allowed_aspects )
       shared_policies_allowed_aspects = AllowedAspects.new(:user_id => uid, :relationship_type => relation_type, :allowed_aspectids => allowed_aspects)
       shared_policies_allowed_aspects.save
      end

      def reset_policies_h(uid,relation_type)
        AllowedAspects.where(:user_id => uid, :relationship_type => relation_type).find_each do |aspect_id|
        aspect_id.destroy
        end
      end

      def get_user_allowed_aspects_h(uid, relation_type)
         the_allowed_aspects = AllowedAspects.where(:user_id => uid,
                                                      :relationship_type => relation_type)
           if the_allowed_aspects.collect{|pp| pp.allowed_aspectids}.include? -1
             return [-1]
          elsif the_allowed_aspects.collect{|pp| pp.allowed_aspectids}.include? -2
             return [-2]
           elsif the_allowed_aspects.collect{|pp| pp.allowed_aspectids}.include? -3
             return [-3]
           else
              # aspects = get_user_aspect_ids(uid)
             return the_allowed_aspects.collect{|pp| pp.allowed_aspectids}
           end
      end

    # policies for disallowed aspects

    def add_dis_policies(uid, relation_type, disallowed_aspects )
      shared_policies_disallowed_aspects = DisallowedAspects.new(:user_id => uid, :relationship_type => relation_type, :disallowed_aspectids => disallowed_aspects)
      shared_policies_disallowed_aspects.save
    end

    def reset_dis_policies_h(uid,relation_type)
      DisallowedAspects.where(:user_id => uid, :relationship_type => relation_type).find_each do |aspect_id|
        aspect_id.destroy
      end
    end

    def get_user_disallowed_aspects_h(uid, relation_type)
      the_disallowed_aspects = DisallowedAspects.where(:user_id => uid,
                                                 :relationship_type => relation_type)
      if the_disallowed_aspects.collect{|pp| pp.disallowed_aspectids}.include? -3
        return [-3]
      elsif the_disallowed_aspects.collect{|pp| pp.disallowed_aspectids}.include? -4
        return [-4]
      elsif the_disallowed_aspects.collect{|pp| pp.disallowed_aspectids}.include? -5
        return [-5]
      elsif the_disallowed_aspects.collect{|pp| pp.disallowed_aspectids}.include? -6
        return [-6]
      # else
      #   # aspects = get_user_aspect_ids(uid)
      #   return the_disallowed_aspects.collect{|pp| pp.disallowed_aspectids}
      end
    end

    # sensitive level of shared items

      def add_shared_items_sensitive_level_policies(uid, post_type, sensitive_level )
          shared_policies_shared_items_sensitive_level = PostsSensitiveLevels.new(:user_id => uid, :post_type => post_type, :sensitive_level => sensitive_level)
          shared_policies_shared_items_sensitive_level.save
      end

      def reset_policies_of_shared_items_sensitive_level(uid,post_type)
        PostsSensitiveLevels.where(:user_id => uid, :post_type => post_type).find_each do |sl|
        sl.destroy
        end
      end

      # sensitive level of aspects

        def add_aspects_sensitive_level_policies(uid, relationship_type, sensitive_level )
          sensitivity_level_of_aspect=AspectsLevelsOfSenstivityAndTrust.new(:user_id => uid,:relationship_type => relationship_type,:sensitive_level => sensitive_level)
          sensitivity_level_of_aspect.save
        end

        def reset_policies_of_aspect_sensitive_level(uid, relationship_type)
          AspectsLevelsOfSenstivityAndTrust.where(:user_id => uid,:relationship_type => relationship_type).find_each do |sl|
            sl.destroy
          end
        end

       # trust level of aspects

        def add_aspects_trust_level_policies(uid, relationship_type, trust_level )
          AspectsLevelsOfSenstivityAndTrust.where(:user_id => uid,:relationship_type => relationship_type).update_all(:trust_level => trust_level)
        end

        def reset_policies_of_aspect_trust_level(uid, relationship_type)
          AspectsLevelsOfSenstivityAndTrust.where(:user_id => uid,:relationship_type => relationship_type).update_all(:trust_level => 0.25)
        end

       # trust threshold value to able to reshare

        def add_threshold_trust_level_policies(uid, trust_threshold_level )
          Person.where(:id => uid).update_all(:tr_threshold => trust_threshold_level)
        end

        def reset_policies_of_threshold_trust_level(uid)
          Person.where(:id => uid).update_all(:tr_threshold => 0.25)
        end

     #  mentioned users who are allowed to reshare
      def get_allowed_mentioned_users_reshare(uid)
        the_allowed_mentioned_users_reshar = ControllersResharingVoting.where(:user_id => uid)
        if the_allowed_mentioned_users_reshar.collect{|pp| pp.allowed_aspects_ids}.include? -1
         return [-1]
        elsif the_allowed_mentioned_users_reshar.collect{|pp| pp.allowed_aspects_ids}.include? -2
         return [-2]
        elsif the_allowed_mentioned_users_reshar.collect{|pp| pp.allowed_aspects_ids}.include? -3
        return [-3]
        else
        return the_allowed_mentioned_users_reshar.collect{|pp| pp.allowed_aspects_ids}
       end
      end

      def add_policies_of_allowed_mentioned_users_to_reshare(uid, allowed_aspects_for_mentioned_users_reshare)
        reshared_policies_mentioned_users = ControllersResharingVoting.new(:user_id => uid, :allowed_aspects_ids => allowed_aspects_for_mentioned_users_reshare)
        reshared_policies_mentioned_users.save
      end

      def reset_policies_of_allowed_mentioned_users_to_reshare(uid)
        ControllersResharingVoting.where(:user_id => uid).find_each do |aspect_id|
          aspect_id.destroy
        end

      end

  end
end
