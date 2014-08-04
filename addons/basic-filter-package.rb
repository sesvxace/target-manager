#--
# Target Manager Basic Filter Package v1.0 by Enelvon
# =============================================================================
#
# Summary
# -----------------------------------------------------------------------------
# This script extends SES Target Manager by providing a number of sample filters
# for use with the Target Manager. They can also serve as examples of how to
# create your own filters.
#
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
# SES Target Manager v1.0 or higher.
#
# **Known Incompatibilities:**
# None. There will never be any - this just adds to the Filters hash present in
# SES::TargetManager.
#
# License
# -----------------------------------------------------------------------------
# This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
#
# Installation
# -----------------------------------------------------------------------------
# Place this script below Materials, but above Main. Place this script below
# SES Target Manager.
#
#++
module SES module TargetManager
  
  Filters.merge!({
    # Always true - use this to create skills that hit all allies and all
    #  enemies.
    /any/i => proc { true },
    # Format as a filter is `hp_>: val` or `mp_>: val`. If % is included, val
    #  is treated as a percentage of the target's maximum hp or mp.
    /((?:h|m)p)_>: (\d+)(%?)/i => proc do |user, target, stat, value, percent|
      stat = stat.downcase
      value = percent ? (target.send("m#{stat}") * (value.to_f / 100)) : value
      target.send("m#{stat}") > value
    end,
    # Format as a filter is `hp_<: val` or `mp_<: val`. If % is included, val
    #  is treated as a percentage of the target's maximum hp or mp.
    /((?:h|m)p)_<: (\d+)(%?)/i => proc do |user, target, stat, value, percent|
      stat = stat.downcase
      value = percent ? (target.send("m#{stat}") * (value.to_f / 100)) : value
      a = target.send(stat) < value
      puts "#{target.send(stat)}, #{value}, #{a}"
      a
    end,
    # Format as a filter is `(x)_=: val`. (x) can be any value present in an
    #  actor or enemy, including things like level. If the value is not present
    #  in a target (such as level for enemies), it will return false.
    /(.+)+?_=: (\d+)/ => proc do |user, target, stat, value|
      target.send(stat) == value.to_i rescue false
    end,
    # Format as a filter is `(x)_!=: val`. (x) can be any value present in an
    #  actor or enemy, including things like level. If the value is not present
    #  in a target (such as level for enemies), it will return false.
    /(.+)+?_!=: (\d+)/ => proc do |user, target, stat, value|
      target.send(stat) != value.to_i rescue false
    end,
    # Format as a filter is `(x)_>: val`. (x) can be any value present in an
    #  actor or enemy, including things like level. If the value is not present
    #  in a target (such as level for enemies), it will return false.
    /(.+)+?_>: (\d+)/ => proc do |user, target, stat, value|
      target.send(stat) > value.to_i rescue false
    end,
    # Format as a filter is `(x)_<: val`. (x) can be any value present in an
    #  actor or enemy, including things like level. If the value is not present
    #  in a target (such as level for enemies), it will return false.
    /(.+)+?_<: (\d+)/ => proc do |user, target, stat, value|
      target.send(stat) < value.to_i rescue false
    end,
    # Format as a filter is `enemy_only` or `actor_only`. Used to filter targets
    #  to only Actors or only Enemies.
    /(enemy|actor)_only/i => proc do |user, target, type|
      type[/enemy/i] ? target.is_a?(Game_Enemy) : target.is_a?(Game_Actor)
    end,
    # Format as a filter is `ally_only` or `foe_only`. Used to filter targets
    #  to only allies or only enemies, regardless of whether 'allies' or
    #  'enemies' refer to Actors or Enemies.
    /(ally|foe)_only/i => proc do |user, target, type|
      group = type[/ally/i] ? user.friends_unit : user.opponents_unit
      group.include?(target)
    end,
    # Format as a filter is `has_state: (x)`. (x) is the ID number of a state.
    #  Targets must have the specified state.
    /has_state: (\d+)/i => proc do |user, target, state|
      target.state?(state.to_i)
    end,
    # Format as a filter is `not_state: (x)`. (x) is the ID number of a state.
    #  Targets cannot have the specified state.
    /not_state: (\d+)/i => proc do |user, target, state|
      !target.state?(state.to_i)
    end,
    # Format as a filter is `not_user`. Prevents the user from being considered
    #  a valid target.
    /not_user/i => proc do |user, target|
      user != target
    end,
  })
end end
