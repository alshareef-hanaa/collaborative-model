#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :public, :user_photo]
  before_filter -> { @css_framework = :bootstrap }, only: [:privacy_settings,:sharing_privacy_settings, :edit]

  layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }, only: [:privacy_settings, :sharing_privacy_settings, :edit]

  use_bootstrap_for :getting_started

  respond_to :html

  include Kbl

  def edit
    @aspect = :user_edit
    @user   = current_user
    @email_prefs = Hash.new(true)
    @user.user_preferences.each do |pref|
      @email_prefs[pref.email_type] = false
    end
  end
  # ------------- Added by Hanaa ---------------
  # get senstive level of aspects : done

  # get senstive levl of shared item :done

  # get allawed aspects :done

  # get trust level for each aspect :done

  # get threshold value to reshare


  def privacy_settings
    @blocks = current_user.blocks.includes(:person)
    @aspects = Aspect.where(:user_id => current_user.id)
    @disallowed_options={"I do not care"=> -3, "Everyone does not belong to your aspects list"=> -4, "Aspects that did not select as allowed "=> -5,"Everyone"=> -6 }
    @sensitive_options={"Minimum"=> 0.01,"Low"=> 0.25, "Mid"=> 0.50, "High"=> 1.00}
    @trust_level_options={"Low"=> 0.25, "Mid"=> 0.50, "High"=> 1.00}

    # Create a privacy handler to add or remove privacy policies
    handler = Privacy::Handler.new

    #---------------- Added by Hanaa ------------

    # ------ Get allowed aspects for each uploader R types-------

    # First Friends' posts allowed aspects
     # ** allowed aspects **
     # check whether posts from friends has privacy policies (allowed any aspects)
      friends_posts_privacy_policy_1 = AllowedAspects.where(:user_id => current_user.id, :relationship_type => "Friends")
      #check if user care about allowed who can access his/her friends' posts
      @allowed_aspectsids_friends_posts = false
      friendsp_1= friends_posts_privacy_policy_1.first
      if friendsp_1 !=nil
        @allowed_aspectsids_friends_posts=true
       # Get all allowed aspects for post from friend
       allowed_aspectsids_friend = handler.get_user_allowed_aspects_h(current_user.id, "Friends")
       @allowed_aspectsids_for_friends_post = []
       allowed_aspectsids_friend.each do |da|
       @allowed_aspectsids_for_friends_post.push(da)
        end
      end
    # ** disallowed aspects **
    # check whether posts from friends have privacy policies (disallowed any aspects)
    friends_posts_privacy_policy_2 = DisallowedAspects.where(:user_id => current_user.id, :relationship_type => "Friends")
    #check if user care about disallowed who can access his/her friends posts
    @disallowed_aspects_friends_posts= false
    friendsp_2 = friends_posts_privacy_policy_2.first
    if friendsp_2 !=nil
      @disallowed_aspects_friends_posts=true
      # Get all disallowed aspects for post from friends
      disallowed_aspectsids_friends = handler.get_user_disallowed_aspects_h(current_user.id, "Friends")
      @disallowed_aspectsids_for_friends_post = []
      disallowed_aspectsids_friends.each do |da|
        @disallowed_aspectsids_for_friends_post.push(da)
      end
    end


    # Second Family members' posts allowed aspects
    # ** allowed aspects **
    # check whether posts from family members have privacy policies (allowed any aspects)
    family_members_posts_privacy_policy = AllowedAspects.where(:user_id => current_user.id, :relationship_type => "Family")
    #check if user care about allowed who can access his/her family members' posts
    @allowed_aspects_family_members_posts= false
    familyp_1 = family_members_posts_privacy_policy.first
    if familyp_1 !=nil
      @allowed_aspects_family_members_posts=true
      # Get all allowed aspects for post from friend
      allowed_aspectsids_family = handler.get_user_allowed_aspects_h(current_user.id, "Family")
      @allowed_aspectsids_for_family_members_post = []
      allowed_aspectsids_family.each do |da|
        @allowed_aspectsids_for_family_members_post.push(da)
      end
    end
    # ** disallowed aspects **
    # check whether posts from Family members have privacy policies (disallowed any aspects)
    family_members_posts_privacy_policy_2 = DisallowedAspects.where(:user_id => current_user.id, :relationship_type => "Family")
    #check if user care about disallowed who can access his/her family members posts
    @disallowed_aspects_family_members_posts= false
    familyp_2 = family_members_posts_privacy_policy_2.first
    if familyp_2 !=nil
      @disallowed_aspects_family_members_posts=true
      # Get all disallowed aspects for post from family members
      disallowed_aspectsids_family = handler.get_user_disallowed_aspects_h(current_user.id, "Family")
      @disallowed_aspectsids_for_family_members_post = []
      disallowed_aspectsids_family.each do |da|
        @disallowed_aspectsids_for_family_members_post.push(da)
      end
    end

   # Third  coworkers posts allowed aspects
    # ** allowed aspects **
    # check whether posts from coworkers have privacy policies (allowed or disallowed any aspects)
    coworkers_posts_privacy_policy_1 = AllowedAspects.where(:user_id => current_user.id, :relationship_type => "Work")
    #check if user care about allowed who can access his/her coworkers posts
    @allowed_aspects_coworkers_posts= false
    coworkersp_1 = coworkers_posts_privacy_policy_1.first
    if coworkersp_1 !=nil
      @allowed_aspects_coworkers_posts=true
      # Get all allowed aspects for post from coworkers
      allowed_aspectsids_coworker = handler.get_user_allowed_aspects_h(current_user.id, "Work")
      @allowed_aspectsids_for_coworkers_post = []
      allowed_aspectsids_coworker.each do |da|
        @allowed_aspectsids_for_coworkers_post.push(da)
      end
    end
    # ** disallowed aspects **
    # check whether posts from cowrkers have privacy policies (disallowed any aspects)
    coworkers_posts_privacy_policy_2 = DisallowedAspects.where(:user_id => current_user.id, :relationship_type => "Work")
    #check if user care about disallowed who can access his/her cowrkers posts
    @disallowed_aspects_workers_posts= false
    coworkersp_2 = coworkers_posts_privacy_policy_2.first
    if coworkersp_2 !=nil
      @disallowed_aspects_coworkers_posts=true
      # Get all disallowed aspects for post from coworkers
      disallowed_aspectsids_coworker = handler.get_user_disallowed_aspects_h(current_user.id, "Work")
      @disallowed_aspectsids_for_coworkers_post = []
      disallowed_aspectsids_coworker.each do |da|
        @disallowed_aspectsids_for_coworkers_post.push(da)
      end
    end


    # Fourth acquaintances posts
    # ** allowed aspects **
    # check whether posts from acquaintances have privacy policies (allowed or disallowed any aspects)
    acquaintances_posts_privacy_policy_1 = AllowedAspects.where(:user_id => current_user.id, :relationship_type => "Acquaintances")
    #check if user care about allowed who can access his/her acquaintances posts
    @allowed_aspects_acquaintances_posts= false
    acquaintancesp_1 = acquaintances_posts_privacy_policy_1.first
    if acquaintancesp_1 !=nil
      @allowed_aspects_acquaintances_posts=true
      # Get all allowed aspects for post from acquaintances
      allowed_aspectsids_acquaintances = handler.get_user_allowed_aspects_h(current_user.id, "Acquaintances")
      @allowed_aspectsids_for_acquaintances_post = []
      allowed_aspectsids_acquaintances.each do |da|
        @allowed_aspectsids_for_acquaintances_post.push(da)
      end
    end
    # ** disallowed aspects **
    # check whether posts from acquaintances have privacy policies (disallowed any aspects)
    acquaintances_posts_privacy_policy_2 = DisallowedAspects.where(:user_id => current_user.id, :relationship_type => "Acquaintances")
    #check if user care about disallowed who can access his/her acquaintances posts
    @disallowed_aspects_acquaintances_posts= false
    acquaintancesp_2 = acquaintances_posts_privacy_policy_2.first
    if acquaintancesp_2 !=nil
      @disallowed_aspects_acquaintances_posts=true
      # Get all disallowed aspects for post from acquaintances
      disallowed_aspectsids_acquaintances = handler.get_user_disallowed_aspects_h(current_user.id, "Acquaintances")
      @disallowed_aspectsids_for_acquaintances_post = []
      disallowed_aspectsids_acquaintances.each do |da|
        @disallowed_aspectsids_for_acquaintances_post.push(da)
      end
    end


    # ------ Get sensitive level of shared items -----------

    # First location's post
    location_posts_sensitive_level=PostsSensitiveLevels.where(:user_id => current_user.id, :post_type => "location").collect{|e| e.sensitive_level}.first
    location_posts_sensitive_level=location_posts_sensitive_level.to_s
    if location_posts_sensitive_level == "0.01"
      @selected_sl_ption_locaation_posts= "Minimum"
    elsif location_posts_sensitive_level== "0.25"
      @selected_sl_ption_locaation_posts="Low"
    elsif location_posts_sensitive_level== "0.5"
      @selected_sl_ption_locaation_posts="Mid"
    elsif location_posts_sensitive_level== "1.0"
      @selected_sl_ption_locaation_posts="High"
    end

    # Second pic post
    pic_posts_sensitive_level=PostsSensitiveLevels.where(:user_id => current_user.id, :post_type => "picture").collect{|e| e.sensitive_level}.first
    pic_posts_sensitive_level = pic_posts_sensitive_level.to_s
    if pic_posts_sensitive_level == "0.01"
      @selected_sl_option_picture_posts= "Minimum"
    elsif pic_posts_sensitive_level== "0.25"
      @selected_sl_option_picture_posts="Low"
    elsif pic_posts_sensitive_level== "0.5"
      @selected_sl_option_picture_posts="Mid"
    elsif pic_posts_sensitive_level== "1.0"
      @selected_sl_option_picture_posts="High"
    end

    # Third @ post
    mention_posts_sensitive_level=PostsSensitiveLevels.where(:user_id => current_user.id, :post_type => "mention").collect{|e| e.sensitive_level}.first
    mention_posts_sensitive_level = mention_posts_sensitive_level.to_s
      if mention_posts_sensitive_level == "0.01"
        @selected_sl_option_mention_posts= "Minimum"
      elsif mention_posts_sensitive_level== "0.25"
        @selected_sl_option_mention_posts="Low"
      elsif mention_posts_sensitive_level== "0.5"
        @selected_sl_option_mention_posts="Mid"
      elsif mention_posts_sensitive_level== "1.0"
        @selected_sl_option_mention_posts="High"
      end

    # ------- Get sensitive level of aspects -------
    #  Friends
     friends_aspects_sensitive_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Friends").collect{|e| e.sensitive_level}.first
     friends_aspects_sensitive_level=friends_aspects_sensitive_level.to_s
     if friends_aspects_sensitive_level== "0.01"
       @selected_sl_ption_friends_aspect="Minimum"
     elsif friends_aspects_sensitive_level== "0.25"
       @selected_sl_ption_friends_aspect="Low"
     elsif friends_aspects_sensitive_level== "0.5"
       @selected_sl_ption_friends_aspect="Mid"
     elsif friends_aspects_sensitive_level== "1.0"
       @selected_sl_ption_friends_aspect="High"
     end

    #  Family
    family_aspects_sensitive_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Family").collect{|e| e.sensitive_level}.first
    family_aspects_sensitive_level=family_aspects_sensitive_level.to_s
    if family_aspects_sensitive_level== "0.01"
      @selected_sl_option_family_aspect="Minimum"
    elsif family_aspects_sensitive_level== "0.25"
      @selected_sl_option_family_aspect="Low"
    elsif family_aspects_sensitive_level== "0.5"
      @selected_sl_option_family_aspect="Mid"
    elsif family_aspects_sensitive_level== "1.0"
      @selected_sl_option_family_aspect="High"
    end

    #  Coworker
    work_aspects_sensitive_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Work").collect{|e| e.sensitive_level}.first
    work_aspects_sensitive_level=work_aspects_sensitive_level.to_s
    if work_aspects_sensitive_level== "0.01"
      @selected_sl_option_work_aspect="Minimum"
    elsif work_aspects_sensitive_level== "0.25"
      @selected_sl_option_work_aspect="Low"
    elsif work_aspects_sensitive_level== "0.5"
      @selected_sl_option_work_aspect="Mid"
    elsif work_aspects_sensitive_level== "1.0"
      @selected_sl_option_work_aspect="High"
    end

    # Acquaintances
    acquaintances_aspects_sensitive_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Work").collect{|e| e.sensitive_level}.first
    acquaintances_aspects_sensitive_level=acquaintances_aspects_sensitive_level.to_s
    if acquaintances_aspects_sensitive_level== "0.01"
      @selected_sl_option_acquaintances_aspect="Minium"
    elsif acquaintances_aspects_sensitive_level== "0.25"
      @selected_sl_option_acquaintances_aspect="Low"
    elsif acquaintances_aspects_sensitive_level== "0.5"
      @selected_sl_option_acquaintances_aspect="Mid"
    elsif acquaintances_aspects_sensitive_level== "1.0"
      @selected_sl_option_acquaintances_aspect="High"
    end

    # ------ Get trust level of aspects -----------

    #  Friends
    friends_aspects_trust_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Friends").collect{|e| e.trust_level}.first
    friends_aspects_trust_level=friends_aspects_trust_level.to_s
    if friends_aspects_trust_level== "0.25"
      @selected_tl_option_friends_aspect="Low"
    elsif friends_aspects_trust_level== "0.5"
      @selected_tl_option_friends_aspect="Mid"
    elsif friends_aspects_trust_level== "1.0"
      @selected_tl_option_friends_aspect="High"
    end

    #  Family
    family_aspects_trust_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Family").collect{|e| e.trust_level}.first
    family_aspects_trust_level=family_aspects_trust_level.to_s
    if family_aspects_trust_level== "0.25"
      @selected_tl_option_family_aspect="Low"
    elsif family_aspects_trust_level== "0.5"
      @selected_tl_option_family_aspect="Mid"
    elsif family_aspects_trust_level== "1.0"
      @selected_tl_option_family_aspect="High"
    end

    #  Coworker
    work_aspects_trust_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Work").collect{|e| e.trust_level}.first
    work_aspects_trust_level=work_aspects_trust_level.to_s
    if work_aspects_trust_level== "0.25"
      @selected_tl_option_work_aspect="Low"
    elsif work_aspects_trust_level== "0.5"
      @selected_tl_option_work_aspect="Mid"
    elsif work_aspects_trust_level== "1.0"
      @selected_tl_option_work_aspect="High"
    end

    # Acquaintances
    acquaintances_aspects_trust_level=AspectsLevelsOfSenstivityAndTrust.where(:user_id => current_user.id, :relationship_type => "Acquaintances").collect{|e| e.trust_level}.first
    acquaintances_aspects_trust_level=acquaintances_aspects_trust_level.to_s
    if acquaintances_aspects_trust_level== "0.25"
      @selected_tl_option_acquaintances_aspect="Low"
    elsif acquaintances_aspects_trust_level== "0.5"
      @selected_tl_option_acquaintances_aspect="Mid"
    elsif acquaintances_aspects_trust_level== "1.0"
      @selected_tl_option_acquaintances_aspect="High"
    end

    # ------ Get trust threshold value to reshare -----------

    trust_threshold_value=Person.where(:id => current_user.id).collect{|e| e.tr_threshold}.first
    trust_threshold_value=trust_threshold_value.to_s
      if trust_threshold_value== "0.25"
        @tr_threshold_option="Low"
      elsif trust_threshold_value== "0.5"
        @tr_threshold_option="Mid"
      elsif trust_threshold_value== "1.0"
        @tr_threshold_option="High"
      end

    # --------- Get mentioned user who are allowed to reshare -------

    allowed_mentioned_users_reshare = ControllersResharingVoting.where(:user_id => current_user.id).collect{|e| e.allowed_aspects_ids}
    if allowed_mentioned_users_reshare !=nil
      # Get all mentioned user who are allowed to reshare
      allowed_mentioned_users_reshare = handler.get_allowed_mentioned_users_reshare(current_user.id)
      @selected_allowed_aspects_reshare = []
      allowed_mentioned_users_reshare.each do |da|
        @selected_allowed_aspects_reshare.push(da)
      end
    end

    # -------------------------------------------------------------------------------------------

    # ------------- Added by me ---------------
    # Get all the location privacy policies of the user
    location_privacy_policies = PrivacyPolicy.where(:user_id => current_user.id, :shareable_type => "Location")

    # Check whether location must be protected
    @protecting_location = false

    # Get the blocking and hiding flag from the first row (all row will have the same, TODO makes it per policy basis)
    pp = location_privacy_policies.first
    if pp != nil
      @protecting_location = true
      @block_location = pp.block
      @hide_location = pp.hide


      # Get all disallowed aspects
      disallowed_aspects = handler.get_user_disallowed_aspects(current_user.id, "Location")
      @protected_location = []
      disallowed_aspects.each do |da|
        @protected_location.push(da)
      end
    end

    # location_policy = PrivacyPolicy.where(:user_id => current_user.id,
    #                                       :shareable_type => "Location",
    #                                       :allowed_aspect => nil).first
    #
    # if location_policy != nil
    #   @protecting_location = true
    #   @protected_location = [-1]
    #   @hide_location = location_policy[:hide]
    #   @block_location = location_policy[:block]
    # else
    #   @protecting_location = false
    # end


    # mentions_policy = PrivacyPolicy.where(:user_id => current_user.id,
    #                                       :shareable_type => "Mentions",
    #                                       :allowed_aspect => nil).first
    #
    # if mentions_policy != nil
    #   @protecting_mentions = true
    #   @protected_mentions = [-1]
    #   @hide_mentions = mentions_policy[:hide]
    #   @block_mentions = mentions_policy[:block]
    # else
    #   @protecting_mentions = false
    # end

    # Adding information about Mentions privacy policies
    mention_privacy_policies = PrivacyPolicy.where(:user_id => current_user.id, :shareable_type => "Mentions")

    # Check whether location must be protected
    @protecting_mentions = false

    # Get the blocking and hiding flag from the first row (all row will have the same, TODO makes it per policy basis)
    pp = mention_privacy_policies.first
    if pp != nil
      @protecting_mentions = true
      @block_mentions = pp.block
      @hide_mentions = pp.hide


      # Get all disallowed aspects
      disallowed_aspects = handler.get_user_disallowed_aspects(current_user.id, "Mentions")
      @protected_mentions = []
      disallowed_aspects.each do |da|
        @protected_mentions.push(da)
      end
    end

    # Adding information about Pictures privacy policies
    pictures_privacy_policies = PrivacyPolicy.where(:user_id => current_user.id, :shareable_type => "Pictures")

    # Check whether location must be protected
    @protecting_pics = false

    # Get the blocking and hiding flag from the first row (all row will have the same, TODO makes it per policy basis)
    pp = pictures_privacy_policies.first
    if pp != nil
      @protecting_pics = true
      @block_pics = pp.block
      @hide_pics = pp.hide


      # Get all disallowed aspects
      disallowed_aspects = handler.get_user_disallowed_aspects(current_user.id, "Pictures")
      @protected_pics = []
      disallowed_aspects.each do |da|
        @protected_pics.push(da)
      end
    end

    evolving_location_policy = PrivacyPolicy.where(:user_id => current_user.id,
                                                   :shareable_type => "evolving-location",
                                                   :allowed_aspect => -1).first
    if evolving_location_policy != nil
      @evolving_location = true
    else
      @evolving_location = false
    end

    evolving_weekend_policy = PrivacyPolicy.where(:user_id => current_user.id,
                                                  :shareable_type => "weekend-location")
    if evolving_weekend_policy.blank?
      @weekend_location = false
    else
      @weekend_location = true
      @weekend_pics = []
      evolving_weekend_policy.each do |wa|
        @weekend_pics.push(wa.allowed_aspect)
      end
    end
    # if evolving_weekend_policy != nil
    #   @weekend_location = true
    # else
    #   @weekend_location = false
    # end

    # ------------- Added by me ---------------


    # Testing the kbl module
    @pred = Kbl::Ment.new("Gerardito", "Raulito")
    puts(@pred.to_s)

  end

  # ----------------------------------------- Added by me ----------------------------------------------------
  def set_privacy_policies

    # Create a privacy handler to add or remove privacy policies
    handler = Privacy::Handler.new

     # ------- Added by Hanaa ---------

   # First we take care of allowed and disallowed aspects for each uploader's type (rt)

     # posts form frineds
       # allowed aspects
      if params[:allowed_aspects_friends_posts] !=nil
       # first case: when box of allowed aspects was checked
       # First we remove all rows regarding the allowed aspects for friends posts
      handler.reset_policies_h(current_user.id,"Friends")
      # if user didn't select any option
      if params[:friend_allowed_aspects] ==nil
        handler.add_policies(current_user.id,"Friends",-1)
       # if user selected allowed aspects for his/her friends' post
       # Now we have to create one row per selected aspect
       # We check whether everyone, nobody or doesn't care was selected, and if so we only add that allowed_aspects model
      elsif params[:friend_allowed_aspects].map(&:to_i).include? -1
         handler.add_policies(current_user.id,"Friends",-1)
      elsif params[:friend_allowed_aspects].map(&:to_i).include? -2
            handler.add_policies(current_user.id,"Friends",-2)
      elsif params[:friend_allowed_aspects].map(&:to_i).include? -3
        handler.add_policies(current_user.id,"Friends",-3)
      else
        # Otherwise, for each allowed aspect we add allowed aspect
          params[:friend_allowed_aspects].map(&:to_i).each do |p|
          handler.add_policies(current_user.id,"Friends",p)
        end
      end
      else
        # second case: if didn't check the box for allowed aspects regarding friends'posts
        # then -3 which means our allowed and disallowed aspects
        # in policy are null then this associated controller is not involved in the collaborative decision
        handler.reset_policies_h(current_user.id,"Friends")
        handler.add_policies(current_user.id,"Friends",-3)
      end
     # disallowed aspects
    if params[:disallowed_aspects_friends_posts] !=nil
      # first case: when box of disallowed aspects was checked
      # First we remove all rows regarding the disallowed aspects for friends' posts
      handler.reset_dis_policies_h(current_user.id,"Friends")
      # if user didn't select any option
      if params[:friend_disallowed_aspects] ==nil
        handler.add_dis_policies(current_user.id,"Friends",-6)
        # if user selected disallowed aspects for his/her friends' post
        # Now we have to create one row per selected aspect
        # We check which disallowed option was selected
      elsif params[:friend_disallowed_aspects].map(&:to_i).include? -3
        handler.add_dis_policies(current_user.id,"Friends",-3)
      elsif params[:friend_disallowed_aspects].map(&:to_i).include? -4
        handler.add_dis_policies(current_user.id,"Acquaintances",-4)
      elsif params[:friend_disallowed_aspects].map(&:to_i).include? -5
        handler.add_dis_policies(current_user.id,"Friends",-5)
      elsif params[:friend_disallowed_aspects].map(&:to_i).include? -6
        handler.add_dis_policies(current_user.id,"Friends",-6)
      end
    else
      # second case: if didn't check the box for allowed aspects regarding friends'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_dis_policies_h(current_user.id,"Friends")
      handler.add_dis_policies(current_user.id,"Friends",-3)
    end

     # posts form family members
     # allowed aspects
    if params[:allowed_aspects_family_members_posts] !=nil
      # first case: when box of allowed aspects was checked
      # First we remove all rows regarding the allowed aspects for family members' posts
      handler.reset_policies_h(current_user.id,"Family")
      # if user didn't select any option
      if params[:family_members_allowed_aspects] ==nil
        handler.add_policies(current_user.id,"Family",-1)
        # if user selected allowed aspects for his/her family members' post
        # Now we have to create one row per selected aspect
        # We check whether everyone, nobody or doesn't care was selected, and if so we only add that allowed_aspects model
      elsif params[:family_members_allowed_aspects].map(&:to_i).include? -1
        handler.add_policies(current_user.id,"Family",-1)
      elsif params[:family_members_allowed_aspects].map(&:to_i).include? -2
        handler.add_policies(current_user.id,"Family",-2)
      elsif params[:family_members_allowed_aspects].map(&:to_i).include? -3
        handler.add_policies(current_user.id,"Family",-3)
      else
        # Otherwise, for each allowed aspect we add allowed aspect
        params[:family_members_allowed_aspects].map(&:to_i).each do |p|
          handler.add_policies(current_user.id,"Family",p)
        end
      end
    else
      # second case: if didn't check the box for allowed aspects regarding family members'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_policies_h(current_user.id,"Family")
      handler.add_policies(current_user.id,"Family",-3)
    end
    # disallowed aspects
    if params[:disallowed_aspects_family_members_posts] !=nil
      # first case: when box of disallowed aspects was checked
      # First we remove all rows regarding the disallowed aspects for family members' posts
      handler.reset_dis_policies_h(current_user.id,"Family")
      # if user didn't select any option
      if params[:family_members_disallowed_aspects] ==nil
        handler.add_dis_policies(current_user.id,"Family",-6)
        # if user selected disallowed aspects for his/her family members' post
        # Now we have to create one row per selected aspect
        # We check which disallowed option was selected
      elsif params[:family_members_disallowed_aspects].map(&:to_i).include? -3
        handler.add_dis_policies(current_user.id,"Family",-3)
      elsif params[:family_members_disallowed_aspects].map(&:to_i).include? -4
        handler.add_dis_policies(current_user.id,"Family",-4)
      elsif params[:family_members_disallowed_aspects].map(&:to_i).include? -5
        handler.add_dis_policies(current_user.id,"Family",-5)
      elsif params[:family_members_disallowed_aspects].map(&:to_i).include? -6
        handler.add_dis_policies(current_user.id,"Family",-6)
      end
    else
      # second case: if didn't check the box for allowed aspects regarding family members' posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_dis_policies_h(current_user.id,"Family")
      handler.add_dis_policies(current_user.id,"Family",-3)
    end

    # posts from coworkers
    # allowed aspects
    if params[:allowed_aspects_coworkers_posts] !=nil
      # first case: when box of allowed aspects was checked
      # First we remove all rows regarding the allowed aspects for coworkers' posts
      handler.reset_policies_h(current_user.id,"Work")
      # if user didn't select any option
      if params[:coworkers_allowed_aspects] ==nil
        handler.add_policies(current_user.id,"Work",-1)
        # if user selected allowed aspects for his/her coworkers' post
        # Now we have to create one row per selected aspect
        # We check whether everyone, nobody or doesn't care was selected, and if so we only add that allowed_aspects model
      elsif params[:coworkers_allowed_aspects].map(&:to_i).include? -1
        handler.add_policies(current_user.id,"Work",-1)
      elsif params[:coworkers_allowed_aspects].map(&:to_i).include? -2
        handler.add_policies(current_user.id,"Work",-2)
      elsif params[:coworkers_allowed_aspects].map(&:to_i).include? -3
        handler.add_policies(current_user.id,"Work",-3)
      else
        # Otherwise, for each allowed aspect we add allowed aspect
        params[:coworkers_allowed_aspects].map(&:to_i).each do |p|
          handler.add_policies(current_user.id,"Work",p)
        end
      end
    else
      # second case: if didn't check the box for allowed aspects regarding family members'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_policies_h(current_user.id,"Work")
      handler.add_policies(current_user.id,"Work",-3)
    end
     # disallowed aspects
    if params[:disallowed_aspects_coworkers_posts] !=nil
      # first case: when box of disallowed aspects was checked
      # First we remove all rows regarding the disallowed aspects for coworkers' posts
      handler.reset_dis_policies_h(current_user.id,"Work")
      # if user didn't select any option
      if params[:coworkers_disallowed_aspects] ==nil
        handler.add_dis_policies(current_user.id,"Work",-6)
        # if user selected disallowed aspects for his/her coworkers' post
        # Now we have to create one row per selected aspect
        # We check which disallowed option was selected
      elsif params[:coworkers_disallowed_aspects].map(&:to_i).include? -3
        handler.add_dis_policies(current_user.id,"Work",-3)
      elsif params[:coworkers_disallowed_aspects].map(&:to_i).include? -4
        handler.add_dis_policies(current_user.id,"Work",-4)
      elsif params[:coworkers_disallowed_aspects].map(&:to_i).include? -5
        handler.add_dis_policies(current_user.id,"Work",-5)
      elsif params[:coworkers_disallowed_aspects].map(&:to_i).include? -6
        handler.add_dis_policies(current_user.id,"Work",-6)
      end
    else
      # second case: if didn't check the box for allowed aspects regarding coworkers'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_dis_policies_h(current_user.id,"Work")
      handler.add_dis_policies(current_user.id,"Work",-3)
    end

    #post from acquaintances
    # allowed aspects
    if params[:allowed_aspects_acquaintances_posts] !=nil
      # first case: when box of allowed aspects was checked
      # First we remove all rows regarding the allowed aspects for coworkers' posts
      handler.reset_policies_h(current_user.id,"Acquaintances")
      # if user didn't select any option
      if params[:acquaintances_allowed_aspects] ==nil
        handler.add_policies(current_user.id,"Acquaintances",-1)
        # if user selected allowed aspects for his/her coworkers' post
        # Now we have to create one row per selected aspect
        # We check whether everyone, nobody or doesn't care was selected, and if so we only add that allowed_aspects model
      elsif params[:acquaintances_allowed_aspects].map(&:to_i).include? -1
        handler.add_policies(current_user.id,"Acquaintances",-1)
      elsif params[:acquaintances_allowed_aspects].map(&:to_i).include? -2
        handler.add_policies(current_user.id,"Acquaintances",-2)
      elsif params[:acquaintances_allowed_aspects].map(&:to_i).include? -3
        handler.add_policies(current_user.id,"Acquaintances",-3)
      else
        # Otherwise, for each allowed aspect we add allowed aspect
        params[:acquaintances_allowed_aspects].map(&:to_i).each do |p|
          handler.add_policies(current_user.id,"Acquaintances",p)
        end
      end
    else
      # second case: if didn't check the box for allowed aspects regarding family members'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_policies_h(current_user.id,"Acquaintances")
      handler.add_policies(current_user.id,"Acquaintances",-3)
    end
    # disallowed aspects
    if params[:disallowed_aspects_acquaintances_posts] !=nil
      # first case: when box of disallowed aspects was checked
      # First we remove all rows regarding the disallowed aspects for acquaintances' posts
      handler.reset_dis_policies_h(current_user.id,"Acquaintances")
      # if user didn't select any option
      if params[:acquaintances_disallowed_aspects] ==nil
        handler.add_dis_policies(current_user.id,"Acquaintances",-6)
        # if user selected disallowed aspects for his/her acquaintances' post
        # Now we have to create one row per selected aspect
        # We check which disallowed option was selected
      elsif params[:acquaintances_disallowed_aspects].map(&:to_i).include? -3
        handler.add_dis_policies(current_user.id,"Acquaintances",-3)
      elsif params[:acquaintances_disallowed_aspects].map(&:to_i).include? -4
        handler.add_dis_policies(current_user.id,"Acquaintances",-4)
      elsif params[:acquaintances_disallowed_aspects].map(&:to_i).include? -5
        handler.add_dis_policies(current_user.id,"Acquaintances",-5)
      elsif params[:acquaintances_disallowed_aspects].map(&:to_i).include? -6
        handler.add_dis_policies(current_user.id,"Acquaintances",-6)
      end
    else
      # second case: if didn't check the box for allowed aspects regarding acquaintances'posts
      # then -3 which means our allowed and disallowed aspects
      # in policy are null then this associated controller is not involved in the collaborative decision
      handler.reset_dis_policies_h(current_user.id,"Acquaintances")
      handler.add_dis_policies(current_user.id,"Acquaintances",-3)
    end


    # Second sensitive level of shared items based on their type
     #location's posts
     if params[:sl_location_posts_option] != nil
       handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"location")
       if params[:sl_location_posts_option] == "Minimum"
         handler.add_shared_items_sensitive_level_policies(current_user.id,"location", 0.01)
       elsif params[:sl_location_posts_option] == "Low"
         handler.add_shared_items_sensitive_level_policies(current_user.id,"location", 0.25)
       elsif params[:sl_location_posts_option] == "Mid"
         handler.add_shared_items_sensitive_level_policies(current_user.id,"location", 0.50)
       elsif params[:sl_location_posts_option] == "High"
         handler.add_shared_items_sensitive_level_policies(current_user.id,"location", 1.0)
       end
     else
       handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"location")
       handler.add_shared_items_sensitive_level_policies(current_user.id,"location",0.01)
     end
     # pic posts
      if params[:sl_picture_posts_option] != nil
        handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"picture")
        if params[:sl_picture_posts_option] == "Minimum"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"picture", 0.01)
        elsif params[:sl_picture_posts_option] == "Low"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"picture", 0.25)
        elsif params[:sl_picture_posts_option] == "Mid"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"picture", 0.50)
        elsif params[:sl_picture_posts_option] == "High"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"picture", 1.0)
        end
      else
        handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"picture")
        handler.add_shared_items_sensitive_level_policies(current_user.id,"picture",0.01)
      end
     # @ posts
      if params[:sl_mention_posts_option] != nil
        handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"mention")
        if params[:sl_mention_posts_option] == "Minimum"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"mention", 0.01)
        elsif params[:sl_mention_posts_option] == "Low"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"mention", 0.25)
        elsif params[:sl_mention_posts_option] == "Mid"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"mention", 0.50)
        elsif params[:sl_mention_posts_option] == "High"
          handler.add_shared_items_sensitive_level_policies(current_user.id,"mention", 1.0)
        end
      else
        handler.reset_policies_of_shared_items_sensitive_level(current_user.id,"mention")
        handler.add_shared_items_sensitive_level_policies(current_user.id,"mention",0.01)
      end

    # Third sensitive level of each aspects
     # Friend
      if params[:sl_friends_aspect_option] != nil
        handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Friends")
        if params[:sl_friends_aspect_option] == "Minimum"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Friends", 0.01)
        elsif params[:sl_friends_aspect_option] == "Low"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Friends", 0.25)
        elsif params[:sl_friends_aspect_option] == "Mid"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Friends", 0.50)
        elsif params[:sl_friends_aspect_option] == "High"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Friends", 1.0)
        end
      else
        handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Friends")
        handler.add_aspects_sensitive_level_policies(current_user.id,"Friends",0.01)
      end
    # Family
      if params[:sl_family_aspect_option] != nil
        handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Family")
        if params[:sl_family_aspect_option] == "Minimum"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Family", 0.01)
        elsif params[:sl_family_aspect_option] == "Low"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Family", 0.25)
        elsif params[:sl_family_aspect_option] == "Mid"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Family", 0.50)
        elsif params[:sl_family_aspect_option] == "High"
          handler.add_aspects_sensitive_level_policies(current_user.id,"Family", 1.0)
        end
      else
        handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Family")
        handler.add_aspects_sensitive_level_policies(current_user.id,"Family",0.01)
      end
    # Cowrker
    if params[:sl_coworkers_aspect_option] != nil
      handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Work")
      if params[:sl_coworkers_aspect_option] == "Minimum"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Work", 0.01)
      elsif params[:sl_coworkers_aspect_option] == "Low"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Work", 0.25)
      elsif params[:sl_coworkers_aspect_option] == "Mid"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Work", 0.50)
      elsif params[:sl_coworkers_aspect_option] == "High"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Work", 1.0)
      end
    else
      handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Work")
      handler.add_aspects_sensitive_level_policies(current_user.id,"Work",0.01)
    end
    # acquaintance
    if params[:sl_acquaintances_aspect_option] != nil
      handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Acquaintances")
      if params[:sl_acquaintances_aspect_option] == "Minimum"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Acquaintances", 0.01)
      elsif params[:sl_acquaintances_aspect_option] == "Low"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Acquaintances", 0.25)
      elsif params[:sl_acquaintances_aspect_option] == "Mid"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Acquaintances", 0.50)
      elsif params[:sl_acquaintances_aspect_option] == "High"
        handler.add_aspects_sensitive_level_policies(current_user.id,"Acquaintances", 1.0)
      end
    else
      handler.reset_policies_of_aspect_sensitive_level(current_user.id,"Acquaintances")
      handler.add_aspects_sensitive_level_policies(current_user.id,"Acquaintances",0.01)
    end

    # Fourth trust level of each aspects
      # Friends
      if params[:tl_friends_aspect_option] != nil
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Friends")
        if params[:tl_friends_aspect_option] == "Low"
          handler.add_aspects_trust_level_policies(current_user.id,"Friends", 0.25)
        elsif params[:tl_friends_aspect_option] == "Mid"
          handler.add_aspects_trust_level_policies(current_user.id,"Friends", 0.50)
        elsif params[:tl_friends_aspect_option] == "High"
          handler.add_aspects_trust_level_policies(current_user.id,"Friends", 1.0)
        end
      else
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Friends")
      end
     # Family
      if params[:tl_family_aspect_option] != nil
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Family")
        if params[:tl_family_aspect_option] == "Low"
          handler.add_aspects_trust_level_policies(current_user.id,"Family", 0.25)
        elsif params[:tl_family_aspect_option] == "Mid"
          handler.add_aspects_trust_level_policies(current_user.id,"Family", 0.50)
        elsif params[:tl_family_aspect_option] == "High"
          handler.add_aspects_trust_level_policies(current_user.id,"Family", 1.0)
        end
      else
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Family")
      end
     # coworker
      if params[:tl_coworkers_aspect_option] != nil
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Work")
        if params[:tl_coworkers_aspect_option] == "Low"
          handler.add_aspects_trust_level_policies(current_user.id,"Work", 0.25)
        elsif params[:tl_coworkers_aspect_option] == "Mid"
          handler.add_aspects_trust_level_policies(current_user.id,"Work", 0.50)
        elsif params[:tl_coworkers_aspect_option] == "High"
          handler.add_aspects_trust_level_policies(current_user.id,"Work", 1.0)
        end
      else
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Family")
      end
     # acquaintances
      if params[:tl_acquaintances_aspect_option] != nil
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Acquaintances")
        if params[:tl_acquaintances_aspect_option] == "Low"
          handler.add_aspects_trust_level_policies(current_user.id,"Acquaintances", 0.25)
        elsif params[:tl_acquaintances_aspect_option] == "Mid"
          handler.add_aspects_trust_level_policies(current_user.id,"Acquaintances", 0.50)
        elsif params[:tl_acquaintances_aspect_option] == "High"
          handler.add_aspects_trust_level_policies(current_user.id,"Acquaintances", 1.0)
        end
      else
        handler.reset_policies_of_aspect_trust_level(current_user.id,"Acquaintances")
      end

    # Fifth trust threshold value to able to reshare
      if params[:tr_threshold] != nil
        handler.reset_policies_of_threshold_trust_level(current_user.id)
        if params[:tr_threshold] == "Low"
          handler.add_threshold_trust_level_policies(current_user.id, 0.25)
        elsif params[:tr_threshold] == "Mid"
          handler.add_threshold_trust_level_policies(current_user.id, 0.50)
        elsif params[:tr_threshold] == "High"
          handler.add_threshold_trust_level_policies(current_user.id, 1.0)
        end
      else
        handler.reset_policies_of_threshold_trust_level(current_user.id)
      end

     # sixth allowed aspects which their members (who consider here as mentioned users) are allowed to re-share

      # if params[:allowed_aspects_coworkers_posts] !=nil
      #   # first case: when box of allowed aspects was checked
      #   # First we remove all rows regarding the allowed aspects for coworkers' posts
      #   handler.reset_policies_h(current_user.id,"Work")
      #   # if user didn't select any option then don't participate in collabritave decision
        if params[:allowed_aspects_reshare] !=nil
           handler.reset_policies_of_allowed_mentioned_users_to_reshare(current_user.id)
          # if user selected allowed aspects for his/her coworkers' post
          # Now we have to create one row per selected aspect
          # We check whether everyone, nobody or doesn't care was selected, and if so we only add that allowed_aspects model
          if params[:allowed_aspects_reshare].map(&:to_i).include? -1
            handler.add_policies_of_allowed_mentioned_users_to_reshare(current_user.id,-1)
          elsif params[:allowed_aspects_reshare].map(&:to_i).include? -2
            handler.add_policies_of_allowed_mentioned_users_to_reshare(current_user.id,-2)
          elsif params[:allowed_aspects_reshare].map(&:to_i).include? -3
            handler.add_policies_of_allowed_mentioned_users_to_reshare(current_user.id,-3)
          else
            # Otherwise, for each allowed aspect we add allowed aspect
            params[:allowed_aspects_reshare].map(&:to_i).each do |p|
              handler.add_policies_of_allowed_mentioned_users_to_reshare(current_user.id,p)
            end
          end
        else
          handler.add_policies_of_allowed_mentioned_users_to_reshare(current_user.id,-1)
        end

      #   # second case: if didn't check the box for allowed aspects regarding family members'posts
      #   # then -3 which means our allowed and disallowed aspects
      #   # in policy are null then this associated controller is not involved in the collaborative decision
      #   handler.reset_policies_h(current_user.id,"Work")
      #   handler.add_policies(current_user.id,"Work",-3)
      # end

     # -----------------------------------------------
    # if :protect_location is equal to 1 it means that it was marked, if
    # :protect_location is empty it means that is was not

    puts("Nothing was selected") if params[:location_aspects] == nil


    # First we take care of the location policies

    # We check that the user checked to protect her/his location to
    # any of the her/his aspects
    if params[:location_aspects] != nil
      # --------------------------- TODO
      # First we remove all rows regarding the location policy
      handler.reset_policies("Location",current_user.id)
      # Now we have to create one row per selected aspect

      # We take the aspects which have access to the location
      ## First we get all the aspects ids of the user
      # aspects = handler.get_user_aspect_ids(current_user.id)
      # Finally, we subtract the aspects are not allowed, i.e. the ones selected
      # in the UI (note that -1 does not appear in the array aspects therefore
      # it will never be in allowed_aspects)
      # allowed_aspects = aspects.map(&:to_i) - params[:location_aspects].map(&:to_i)

      # We checke whether everyone was selected, and if so we only add that privacy policy
      if params[:location_aspects].map(&:to_i).include? -1
        handler.add_policy(current_user.id,"Location",params[:block_location],params[:hide_location],-1)
      else
        # Otherwise, for each allowed aspect we add a privacy policy
        params[:location_aspects].map(&:to_i).each do |p|
          handler.add_policy(current_user.id,"Location",params[:block_location],params[:hide_location],p)
        end
      end
    else
      # --------------------------- TODO
      # If none of the aspects were selected, the user is allowing
      # everyone to access (in the audience of the post) to access the
      # information, therefore we remove all privacy policies
      handler.reset_policies("Location",current_user.id)
    end




    # Informing and storing user about protecting his/her mentions
    if params[:protect_mentions]
      # --------------------------- TODO
      # First we remove all rows regarding the location policy
      handler.reset_policies("Mentions",current_user.id)
      # Now we have to create one row per selected aspect

      # We take the aspects which have access to the location
      ## First we get all the aspects ids of the user
      # aspects = handler.get_user_aspect_ids(current_user.id)
      # Finally, we subtract the aspects are not allowed, i.e. the ones selected
      # in the UI (note that -1 does not appear in the array aspects therefore
      # it will never be in allowed_aspects)
      # allowed_aspects = aspects.map(&:to_i) - params[:mentions_aspects].map(&:to_i)

      # We checke whether everyone was selected, and if so we only add that privacy policy
      if params[:mentions_aspects].map(&:to_i).include? -1
        handler.add_policy(current_user.id,"Mentions",params[:block_mentions],params[:hide_mentions],-1)
      else
        # Otherwise, for each allowed aspect we add a privacy policy
        params[:mentions_aspects].map(&:to_i).each do |p|
          handler.add_policy(current_user.id,"Mentions",params[:block_mentions],params[:hide_mentions],p)
        end
      end
    else
      # --------------------------- TODO
      # If none of the aspects were selected, the user is allowing
      # everyone to access (in the audience of the post) to access the
      # information, therefore we remove all privacy policies
      handler.reset_policies("Mentions",current_user.id)
    end

    if params[:protect_pics]
      # --------------------------- TODO
      # First we remove all rows regarding the location policy
      handler.reset_policies("Pictures",current_user.id)
      # Now we have to create one row per selected aspect

      # We take the aspects which have access to the location
      ## First we get all the aspects ids of the user
      # aspects = handler.get_user_aspect_ids(current_user.id)
      # Finally, we subtract the aspects are not allowed, i.e. the ones selected
      # in the UI (note that -1 does not appear in the array aspects therefore
      # it will never be in allowed_aspects)
      # allowed_aspects = aspects.map(&:to_i) - params[:pics_aspects].map(&:to_i)

      # We checke whether everyone was selected, and if so we only add that privacy policy
      if params[:pics_aspects].map(&:to_i).include? -1
        handler.add_policy(current_user.id,"Pictures",params[:block_pics],params[:hide_pics],-1)
      else
        # Otherwise, for each allowed aspect we add a privacy policy
        params[:pics_aspects].map(&:to_i).each do |p|
          handler.add_policy(current_user.id,"Pictures",params[:block_pics],params[:hide_pics],p)
        end
      end
    else
      # --------------------------- TODO
      # If none of the aspects were selected, the user is allowing
      # everyone to access (in the audience of the post) to access the
      # information, therefore we remove all privacy policies
      handler.reset_policies("Pictures",current_user.id)
    end



    # !!!!!!Think how to start it once at the beginning and no more times!!!!!!!!!1

    # Create a handler to add policies to the database
    # Now initialised at the beginning of the method

    # Create an automaton controller
    automaton = Privacy::Automata.new(true)
    if params[:evolving_location]
      #Start automaton (if it wasn't before)
      if (defined?($larva_running)).nil?
        puts "Larva was not running, therefore we start it"
        automaton.startLarvaProtocol()
        #Indicate the larva is running
        $larva_running = true
      else
        puts "Larva was already running, therefore we only add the evolving policy to the database"
      end
      #Add the policy to the database
      handler.reset_policies("evolving-location",current_user.id)
      handler.add_policy(current_user.id,"evolving-location",0,0,-1)
    else
      puts "Deleting location evolving policy of user " + current_user.id.to_s
      handler.reset_policies("evolving-location",current_user.id)
    end



    # TO-DO: Think of how to remove all the repeted code!!!!!!!!!!!!!!!!
    if params[:weekend_location]
      #Start automaton (if it wasn't before)
      if (defined?($larva_running)).nil?
        puts "Larva was not running, therefore we start it"
        automaton.startLarvaProtocol()
        #Indicate the larva is running
        $larva_running = true
      else
        puts "Larva was already running, therefore we only add the evolving policy to the database"
      end
      if (defined?($weekend_running)).nil?
        automaton.startLarvaWeekendNotifier()
      else
        puts "Weekend notifier already running"
      end
      #Add the policy to the database
      # aspects = handler.get_user_aspect_ids(current_user.id)
      # allowed_aspects = aspects.map(&:to_i) - params[:weekend_aspects].map(&:to_i)

      # if params[:weekend_aspects].map(&:to_i).include? -1
      #   handler.add_policy(current_user.id,"weekend-location",0,0,-1)
      # else
      #   # Otherwise, for each allowed aspect we add a privacy policy
      handler.reset_policies("weekend-location",current_user.id)
      params[:weekend_aspects].each do |a|
        handler.add_policy(current_user.id,"weekend-location",0,0,a)
      end
      # end
    else
      puts "Deleting weekend-location evolving policy of user " + current_user.id.to_s
      handler.delete_policy("weekend-location",current_user.id)
    end

    message_to_show = "Your privacy policies have been successfully updated"

    flash[:notice] = message_to_show

    # We go back to the privacy page
    redirect_to '/privacy'
  end

  # Auxiliary function to add privacy policies to the database
  # TODO: Move this method to an external library file
  # def add_policy(shareable, to_block, to_hide)
  #   return_message = ""
  #   user = current_user
  #   policyTemp = PrivacyPolicy.where(:user_id => user.id,
  #                                    :shareable_type => shareable).first
  #     if policyTemp != nil
  #       return_message = "Diaspora is already protecting your " + shareable
  #     else
  #       policy = PrivacyPolicy.new(:user_id => user.id,
  #                                  :shareable_type => shareable,
  #                                  :block => to_block == "yes" ? 1 : 0, # Take the input from the user
  #                                  :hide => to_hide == "yes" ? 1 : 0, # Take the input from the user
  #                                  :allowed_aspect => nil) # Take the input from the user
  #       policy.save
  #       return_message = "Diaspora is protecting your " + shareable
  #     end
  #   return return_message
  # end

  # Auxiliary function to delete privacy policies from the database
  # TODO: Move this method to an external library file
  # def delete_policy(shareable)
  #   user = current_user
  #   policy = PrivacyPolicy.where(:user_id => user.id,
  #                                 :shareable_type => shareable).first
  #   policy.destroy if policy != nil
  #   return "Diaspora is *NOT* protecting your " + shareable
  # end


  def update
    password_changed = false
    @user = current_user

    if u = user_params
      u.delete(:password) if u[:password].blank?
      u.delete(:password_confirmation) if u[:password].blank? and u[:password_confirmation].blank?
      u.delete(:language) if u[:language].blank?

      # change email notifications
      if u[:email_preferences]
        @user.update_user_preferences(u[:email_preferences])
        flash[:notice] = I18n.t 'users.update.email_notifications_changed'
      # change password
      elsif u[:current_password] && u[:password] && u[:password_confirmation]
        if @user.update_with_password(u)
          password_changed = true
          flash[:notice] = I18n.t 'users.update.password_changed'
        else
          flash[:error] = I18n.t 'users.update.password_not_changed'
        end
      elsif u[:show_community_spotlight_in_stream] || u[:getting_started]
        if @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.settings_updated'
        else
          flash[:notice] = I18n.t 'users.update.settings_not_updated'
        end
      elsif u[:language]
        if @user.update_attributes(u)
          I18n.locale = @user.language
          flash[:notice] = I18n.t 'users.update.language_changed'
        else
          flash[:error] = I18n.t 'users.update.language_not_changed'
        end
      elsif u[:email]
        @user.unconfirmed_email = u[:email]
        if @user.save
          @user.mail_confirm_email == @user.email
          if @user.unconfirmed_email
            flash[:notice] = I18n.t 'users.update.unconfirmed_email_changed'
          end
        else
          flash[:error] = I18n.t 'users.update.unconfirmed_email_not_changed'
        end
      elsif u[:auto_follow_back]
        if  @user.update_attributes(u)
          flash[:notice] = I18n.t 'users.update.follow_settings_changed'
        else
          flash[:error] = I18n.t 'users.update.follow_settings_not_changed'
        end
      end
    end

    respond_to do |format|
      format.js   { render :nothing => true, :status => 204 }
      format.all  { redirect_to password_changed ? new_user_session_path : edit_user_path }
    end
  end

  def destroy
    if params[:user] && params[:user][:current_password] && current_user.valid_password?(params[:user][:current_password])
      current_user.close_account!
      sign_out current_user
      redirect_to(stream_path, :notice => I18n.t('users.destroy.success'))
    else
      if params[:user].present? && params[:user][:current_password].present?
        flash[:error] = t 'users.destroy.wrong_password'
      else
        flash[:error] = t 'users.destroy.no_password'
      end
      redirect_to :back
    end
  end

  def public
    if @user = User.find_by_username(params[:username])
      respond_to do |format|
        format.atom do
          @posts = Post.where(author_id: @user.person_id, public: true)
                    .order('created_at DESC')
                    .limit(25)
                    .map {|post| post.is_a?(Reshare) ? post.absolute_root : post }
                    .compact
        end

        format.any { redirect_to person_path(@user.person) }
      end
    else
      redirect_to stream_path, :error => I18n.t('users.public.does_not_exist', :username => params[:username])
    end
  end

  def getting_started
    @user     = current_user
    @person   = @user.person
    @profile  = @user.profile

    respond_to do |format|
    format.mobile { render "users/getting_started" }
    format.all { render "users/getting_started", layout: "with_header_with_footer" }
    end
  end

  def getting_started_completed
    user = current_user
    user.getting_started = false
    user.save
    redirect_to stream_path
  end

  def export
    exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
    send_data exporter.execute(current_user), :filename => "#{current_user.username}_diaspora_data.xml", :type => :xml
  end

  def export_photos
    tar_path = PhotoMover::move_photos(current_user)
    send_data( File.open(tar_path).read, :filename => "#{current_user.id}.tar" )
  end

  def user_photo
    username = params[:username].split('@')[0]
    user = User.find_by_username(username)
    if user.present?
      redirect_to user.image_url
    else
      render :nothing => true, :status => 404
    end
  end

  def confirm_email
    if current_user.confirm_email(params[:token])
      flash[:notice] = I18n.t('users.confirm_email.email_confirmed', :email => current_user.email)
    elsif current_user.unconfirmed_email.present?
      flash[:error] = I18n.t('users.confirm_email.email_not_confirmed')
    end
    redirect_to edit_user_path
  end

  # Added by me
  def protect_location
    puts("I'm protecting your location")
  end

  private

  def user_params
    params.fetch(:user).permit(
      :email,
      :current_password,
      :password,
      :password_confirmation,
      :language,
      :disable_mail,
      :invitation_service,
      :invitation_identifier,
      :show_community_spotlight_in_stream,
      :auto_follow_back,
      :auto_follow_back_aspect_id,
      :remember_me,
      :getting_started,
      email_preferences: [
        :someone_reported,
        :also_commented,
        :mentioned,
        :comment_on_post,
        :private_message,
        :started_sharing,
        :liked,
        :reshared
      ]
    )
  end
end
