Target Manager v1.0 by Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script is intended to provide a more flexible target manager than the
one present in default Ace. It allows for direct control of what members of
the battle can be targeted by individual skills or items through the use of
filters. It also provides an enhanced version of Ace's random and all target
modes - you can specify ranges for random skills, such as 2-5 hits, and skills
with all or random target modes will have their targets selected via filters.
Any skills that are not tagged as falling under the purview of the Target
Manager will use Ace's default scopes and target methods.

Compatibility Information
-----------------------------------------------------------------------------
**Required Scripts:**
  SES Core v2.2 or higher.

**Known Incompatibilities:**
  None yet, though likely to be incompatible with battle systems that use
their own target managers/target selection windows. Very unlikely to play nice
with the Luna Engine, but untested. Compatibility fix for the Luna Engine is
simple in theory, however.

Usage
-----------------------------------------------------------------------------
  This script is configured in two ways - defining filters and defining the
way that the Target Manager will filter a given skill. Filters are defined in
the Filters hash of the SES::TargetManager module and should consist of a
Regular Expression key and a Proc value that evaluates to true or false. The
base script does not contain any examples - please refer to the Basic Filter
package for a few examples. The package is by no means extensive, though it
should suffice for most basic purposes. I urge you to submit your own filters!
If the community produces enough, I may package them into a Community Filter
Package of some kind.

Now for the part more relevant to most of you: defining the way that the
Target Manager handles filtering for a skill or item.

```
<Target Manager: (one|all|rand)( range)>
  ...FILTER...
  ...FILTER...
</Target Manager>
```

  Place this in a Notes box to tell the Target Manager how it should filter
targets for the skill or item. The first replacement should be one (which
means that it will bring up a filtered list from which the player can choose
a target), all (which means that it will affect all targets who match the
filter), or rand (which means that it will randomly hit targets who match the
filter). If you use the range option, you should also provide a range. If you
want the skill or item to hit 2-5 times, it would look like this:

```
<Target Manager: rand 2..5>
```

  Please note that the rand option requires both a starting point and an end
point, so if you want it to hit 1-3 times you would need to provide the range
1..3 rather than just 3.

  You can include as many filters in between the opening and closing tags as
you would like. To take an example from the basic package, you might have this
as a filter set:

```
<Target Manager: one>
enemy_only
hp_<: 50%
</Target Manager>
```

  This filter would allow the player to choose a target from a list of enemies
with less than 50% of their HP remaining.

Aliased Methods
-----------------------------------------------------------------------------
* `class Game_Action`
    - `make_targets`
* `class Scene_Battle`
    - `create_all_windows`

Overwritten Methods
-----------------------------------------------------------------------------
* `class Scene_Battle`
    - `command_attack`
    - `create_enemy_window`
    - `on_skill_ok`
    - `on_item_ok`

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  This script requires the SES Core (v2.2 or higher). This scripts may be
found in the SES source repository at the following location:

* [Core](https://raw.github.com/sesvxace/core/master/lib/core.rb)

Place this script below Materials, but above Main. Place this script below
the SES Core.
