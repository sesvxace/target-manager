#--
# Target Manager v1.0 by Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script is intended to provide a more flexible target manager than the
# one present in default Ace. It allows for direct control of what members of
# the battle can be targeted by individual skills or items through the use of
# filters. It also provides an enhanced version of Ace's random and all target
# modes - you can specify ranges for random skills, such as 2-5 hits, and skills
# with all or random target modes will have their targets selected via filters.
# Any skills that are not tagged as falling under the purview of the Target
# Manager will use Ace's default scopes and target methods.
# 
# Compatibility Information
# -----------------------------------------------------------------------------
# **Required Scripts:**
#   SES Core v2.2 or higher.
# 
# **Known Incompatibilities:**
#   None yet, though likely to be incompatible with battle systems that use
# their own target managers/target selection windows. Very unlikely to play nice
# with the Luna Engine, but untested. Compatibility fix for the Luna Engine is
# simple in theory, however.
# 
# Usage
# -----------------------------------------------------------------------------
#   This script is configured in two ways - defining filters and defining the
# way that the Target Manager will filter a given skill. Filters are defined in
# the Filters hash of the SES::TargetManager module and should consist of a
# Regular Expression key and a Proc value that evaluates to true or false. The
# base script does not contain any examples - please refer to the Basic Filter
# package for a few examples. The package is by no means extensive, though it
# should suffice for most basic purposes. I urge you to submit your own filters!
# If the community produces enough, I may package them into a Community Filter
# Package of some kind.
# 
# Now for the part more relevant to most of you: defining the way that the
# Target Manager handles filtering for a skill or item.
# 
# ```
# <Target Manager: (one|all|rand)( range)>
#   ...FILTER...
#   ...FILTER...
# </Target Manager>
# ```
# 
#   Place this in a Notes box to tell the Target Manager how it should filter
# targets for the skill or item. The first replacement should be one (which
# means that it will bring up a filtered list from which the player can choose
# a target), all (which means that it will affect all targets who match the
# filter), or rand (which means that it will randomly hit targets who match the
# filter). If you use the range option, you should also provide a range. If you
# want the skill or item to hit 2-5 times, it would look like this:
#
# ```
# <Target Manager: rand 2..5>
# ```
#
#   Please note that the rand option requires both a starting point and an end
# point, so if you want it to hit 1-3 times you would need to provide the range
# 1..3 rather than just 3.
# 
#   You can include as many filters in between the opening and closing tags as
# you would like. To take an example from the basic package, you might have this
# as a filter set:
#
# ```
# <Target Manager: one>
# enemy_only
# hp_<: 50%
# </Target Manager>
# ```
#
#   This filter would allow the player to choose a target from a list of enemies
# with less than 50% of their HP remaining.
# 
# Aliased Methods
# -----------------------------------------------------------------------------
# * `class Game_Action`
#     - `make_targets`
# * `class Scene_Battle`
#     - `create_all_windows`
#
# Overwritten Methods
# -----------------------------------------------------------------------------
# * `class Scene_Battle`
#     - `command_attack`
#     - `create_enemy_window`
#     - `on_skill_ok`
#     - `on_item_ok`
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   This script requires the SES Core (v2.2 or higher). This scripts may be
# found in the SES source repository at the following location:
# 
# * [Core](https://raw.github.com/sesvxace/core/master/lib/core.rb)
# 
# Place this script below Materials, but above Main. Place this script below
# the SES Core.
# 
#++
module SES module TargetManager
  
  # Grab the Basic Filter Package and place it below this script or define your
  # own filters here.
  Filters = {
    # RegEx => Proc
  }
  
  # Evaluates the filters present in a skill or item and creates a list of
  #  targets.
  # 
  # @param action [Game_Action] an action in which the item and user are found
  # @return [Array] array of targets who match the filter
  def self.make_targets(action)
    targets = []
    ($game_party.battle_members + $game_troop.alive_members).each do |target|
      add_target = !action.item.target_filters.any? do |filter|
        !filter[0].call(action.subject, target, *filter[1])
      end
      targets << target if add_target
    end
    return targets
  end
end end

# Base class for Usable Items.
class RPG::UsableItem < RPG::BaseItem
  
  alias_method :en_tm_ui_ssn, :scan_ses_notes
  
  # Scans the notes boxes of skills and items.
  # 
  # @param tags [Hash] hash of tags to search for
  def scan_ses_notes(tags = {})
    @target_type = [:one]
    @target_filters = []
    tags[/^<Target Manager: (one|all|rand)(.+)?>/i] = proc do |type, value|
      @target_type = [type.downcase.to_sym]
      if type == :rand
        if value[/^(\d+)$/] then @target_type << $1.to_i
        elsif value[/^(\d+)(\.+)(\d+)/] then @target_type << [$1.to_i, $2.to_i]
        end
      end
      note[/<Target Manager.+?>\s+(.+)\s+<\/Target Manager>/im]
      if (filters = $1)
        filters.each_line do |c|
          f = SES::TargetManager::Filters.keys.find { |f| c[f] }
          @target_filters << [SES::TargetManager::Filters[f], $~[1..-1]] if f
        end
      end
    end
    en_tm_ui_ssn(tags)
  end
  
  # The scope of the skill or item.
  # 
  # @return [Symbol] a symbol corresponding to the scope
  def target_type
    scan_ses_notes if @target_type.nil?
    @target_type
  end
  
  # The filters used to determine possible targets for the skill or item.
  # 
  # @return [Array] an array of filters
  def target_filters
    scan_ses_notes if @target_filters.nil?
    @target_filters
  end
end

# Base class for action data.
class Game_Action
  attr_accessor :set
  
  alias_method :en_tm_ga_mt, :make_targets
  
  # Creates a list of targets for the action.
  # 
  # @return [Array] an array of targets
  def make_targets
    if @set
      targets = @set and @set = nil
      return targets
    end
    en_tm_ga_mt
  end
end

# Window used for selection. New to the Target Manager.
class Window_BattleTarget < Window_Selectable
  
  # Creates a new instance of the window.
  # 
  # @param info_viewport [Viewport] the viewport that the window belongs to
  # @return [Window_BattleTarget] a new instance of Window_BattleTarget
  def initialize(info_viewport)
    @item_max = 0
    super(0, info_viewport.rect.y, window_width, fitting_height(4))
    @targets = []
    refresh
    self.visible = false
    @info_viewport = info_viewport
  end
  
  # The width of the window.
  # 
  # @return [Integer] the width of the window
  def window_width() Graphics.width - 128 end
  
  # The number of columns in the window.
  # 
  # @return [Integer] the number of columns in the window
  def col_max() return 2 end
  
  # The number of items in the window.
  # 
  # @return [Integer] the number of items in the window
  def item_max() @item_max end
  
  # The current target.
  # 
  # @return [Game_Battler] the currently selected target
  def target() @targets[@index] end
  
  # Whether or not the current slot contains a valid target.
  # 
  # @return [Boolean] whether the target is valid or not
  def current_item_enabled?() target end
  
  # Draws an item in the window.
  # 
  # @param index [Integer] the index at which the item should be drawn
  def draw_item(index)
    change_color(normal_color)
    draw_text(item_rect_for_text(index), @targets[index].name)
  end
  
  # Sets up the window for a given skill or item.
  # 
  # @param [Game_Action] the action containing the skill or item
  def setup(action)
    @targets.clear
    unless action.item.target_filters.empty?
      @targets = SES::TargetManager.make_targets(action)
    else
      item = action.item
      if item.for_opponent?
        @targets = $game_troop.alive_members
      elsif item.for_dead_friend?
        @targets = $game_party.battle_members.select { |actor| actor.dead? }
      else
        $game_party.battle_members.select { |actor| actor.alive? }
      end
    end
    @item_max = @targets.size
    create_contents
    refresh
    show
    activate
  end
  
  # Displays the window.
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  
  # Hides the window.
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
end

# Class that handles much of the battle processing.
class Scene_Battle < Scene_Base
  
  alias_method :en_tm_sb_caw, :create_all_windows
  
  # Creates the windows used in the battle.
  def create_all_windows
    en_tm_sb_caw
    create_target_window
  end
  
  # Creates the enemy target window. Unused.
  def create_enemy_window() end
  
  # Creates the window used by the Target Manager.
  def create_target_window
    @target_window = Window_BattleTarget.new(@info_viewport)
    @target_window.set_handler(:ok,     method(:on_target_ok))
    @target_window.set_handler(:cancel, method(:on_target_cancel))
  end
  
  # Processing when attack is selected.
  def command_attack
    BattleManager.actor.input.set_attack
    select_target_selection
  end
  
  # Processing when a skill is selected.
  def on_skill_ok
    @skill = @skill_window.item
    BattleManager.actor.input.set_skill(@skill.id)
    action = BattleManager.actor.input
    BattleManager.actor.last_skill.object = @skill
    if @skill.target_type[0] == :one then select_target_selection
    else
      case @skill.target_type[0]
      when :all
        BattleManager.actor.input.set = SES::TargetManager.make_targets(action)
      when :rand
        targets, set = [], SES::TargetManager.make_targets(action)
        (@skill.target_type[1][0] + rand(@skill.target_type[1][1])).times do
          targets << set[rand(set.size)]
        end
        BattleManager.actor.input.set = set
      end
      @skill_window.hide
      next_command
    end
  end
  
  # Processing when an item is selected.
  def on_item_ok
    @item = @item_window.item
    BattleManager.actor.input.set_item(@item.id)
    action = BattleManager.actor.input
    case @item.target_type[0]
    when :one
      select_target_selection
    when :all
      BattleManager.actor.input.set = SES::TargetManager.make_targets(action)
    when :rand
      targets, set = [], SES::TargetManager.make_targets(action)
      (@item.target_type[1][0] + rand(@item.target_type[1][1])).times do
        targets << set[rand(set.size)]
      end
      BattleManager.actor.input.set = set
    else
      @item_window.hide
      next_command
    end
    $game_party.last_item.object = @item
  end
  
  # Begins target selection.
  def select_target_selection
    @target_window.setup(BattleManager.actor.input)
  end
  
  # Processing when a target is selected.
  def on_target_ok
    BattleManager.actor.input.set = [@target_window.target]
    @target_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  
  # Processing when target selection is canceled.
  def on_target_cancel
    @target_window.hide
    case @actor_command_window.current_symbol
    when :attack
      @actor_command_window.activate
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end
end