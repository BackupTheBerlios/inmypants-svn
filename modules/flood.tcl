# IMP - Flood checking

###############################################################################
# IMP - an 'AI' TCL script for eggdrops
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

# init our counters
IMP_counter_init "flood" "checks"

# We're going to track flooding PER NICK globally, not per channel
# If someone's flooding us in one place, we'll handle it for all channels
# to stop them being annoying

# HOW IT WORKS
#
# Track a score for each nick
# Reduce the scores by 1 every 30 seconds
# Matching a plugin is one point
# Matching the SAME plugin as before is 3
# Going over 7 will make the bot ignore 50% of what you would trigger
# Going over 15 cuts you out completely

# Message levels: 
#   log: Flood checks
#     d: flood ticks
#     2: flood additions/subtractions

if {![info exists IMP_flood_info]} {
  set IMP_flood_info(_) 0
  set IMP_flood_last(_) ""
  set IMP_flood_lasttext(_) ""
  set IMP_flood_note ""
  set IMP_flood_undo 0
}

proc IMP_flood_tick { min hr a b c } {
  IMP_putloglev 4 * "IMP: flood tick"
  #tick all values down one, to zero
  global IMP_flood_info IMP_flood_last IMP_flood_lasttext
  set stats ""
  foreach element [array names IMP_flood_info] {
    set val $IMP_flood_info($element)
    incr val -2
    if {$val < 0} {
      catch {
        unset IMP_flood_info($element)
      }
      catch {
        unset IMP_flood_last($element)
      }
      catch {
        unset IMP_flood_lasttext($element)
      }
      IMP_putloglev 2 * "IMP: flood tick: $element removed"
    } else {
      append stats "$element:\002$val\002 "
      set IMP_flood_info($element) $val
    }
  }
  if {$stats != ""} {
    IMP_putloglev d * "IMP: flood tick: $stats"
  }
}

proc IMP_flood_add { nick { callback "" } { text "" } } {
  global IMP_flood_info IMP_flood_last IMP_flood_lasttext IMP_flood_last IMP_flood_undo
  set val 1
  if [validuser $nick] {
    set handle $nick
  } else {
    set handle [nick2hand $nick]
    if {$handle == "*"} {
      set handle $nick
    }
  }
  set lastCallback ""
  catch {
    set lastCallback $IMP_flood_last($handle)
  }
  if {$callback != ""} {
    set IMP_flood_last($handle) $callback
    if {$lastCallback == $callback} {
      #naughty
      set val 3
    }
  }

  set lastText ""
  catch {
    set lastText $IMP_flood_lasttext($handle)
  }
  if {$text != ""} {
    set IMP_flood_lasttext($handle) $text
    #putlog "now: $text, last: $lastText"
    if {$lastText == $text} {
      #naughty
      incr val 2
    }
  }

  set flood 0
  catch {
    set flood $IMP_flood_info($handle)
  }
  incr flood $val
  if {$flood > 40} {
    set flood 40
  }
  IMP_putloglev 2 * "IMP: flood added $val to $nick, now $flood"
  set IMP_flood_info($handle) $flood
  set IMP_flood_undo $val
}

proc IMP_flood_clear { nick } {
  global IMP_flood_info IMP_flood_last
  set IMP_flood_info($nick) 0
  set IMP_flood_last($nick) ""
}

proc IMP_flood_remove { nick } {
  global IMP_flood_info 
  set val 1
  if [validuser $nick] {
    set handle $nick
  } else {
    set handle [nick2hand $nick]
    if {$handle == "*"} {
      set handle $nick
    }
  }
  set flood 0
  catch {
    set flood $IMP_flood_info($handle)
  }
  incr flood -1
  if {$flood < 0} {
    return 0
  }
  IMP_putloglev 2 * "IMP: flood removed 1 from $nick, now $flood"
  set IMP_flood_info($handle) $flood
}

proc IMP_flood_undo { nick } {
  global IMP_flood_undo IMP_flood_info IMP_flood_lasttext
  set val $IMP_flood_undo

  #don't knock off the whole value
  if {$val <= 1} {
    return 0
  }

  #incr val -1

  if [validuser $nick] {
    set handle $nick
  } else {
    set handle [nick2hand $nick]
    if {$handle == "*"} {
      set handle $nick
    }
  }

  set flood 0
  catch {
    set flood $IMP_flood_info($handle)
  }
  incr flood [expr 0 - $val]
  if {$flood < 0} {
    set flood 0
  }

  set IMP_flood_info($handle) $flood
  set IMP_flood_lasttext($handle) ""
  set IMP_flood_undo 1
  IMP_putloglev 2 * "IMP: undid flood from $nick, now $flood"
  return 0
}

proc IMP_flood_get { nick } {
  global IMP_flood_info
  if [validuser $nick] {
    set handle $nick
  } else {
    set handle [nick2hand $nick]
    if {$handle == "*"} {
      set handle $nick
    }
  }
  set flood 0
  catch {
    set flood $IMP_flood_info($handle)
  }
  return $flood
}

proc IMP_flood_check { nick } {
  IMP_putloglev 3 * "checking flood for $nick"
  set flood [IMP_flood_get $nick]
  set chance 2
  if {$flood > 35} {
    set chance -1
  }

  if {$flood > 25} {
    set chance -1
  }

  if {$flood > 15} {
    set chance 1
  }
  set r [rand 2]
  if {!($r < $chance)} {
    putlog "IMP: FLOOD check on $nick"
    IMP_counter_incr "flood" "checks"
    return 1
  }
  return 0
}

bind time - "* * * * *" IMP_flood_tick
