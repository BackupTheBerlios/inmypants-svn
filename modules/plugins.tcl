## plugins engine for IMP
#

# Original copyright notice:
###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2002
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
# Modifications are Copyright (C) Dave Wickham 2004
# Released under the GNU GPL; see "COPYING" and the above boilerplate for
# details

## Simple plugins
if [info exists IMP_plugins_simple] { unset IMP_plugins_simple }
set IMP_plugins_simple(dummy) "_{100,100}¦0¦/has a tremendous plugin-related error (wahey)$"

## Admin plugins (.imp)
if [info exists IMP_plugins_admin] { unset IMP_plugins_admin }
set IMP_plugins_admin(dummy) "none"

## complex plugins 
if [info exists IMP_plugins_complex] { unset IMP_plugins_complex }
set IMP_plugins_complex(dummy) "none"

## output plugins 
if [info exists IMP_plugins_output] { unset IMP_plugins_output }
set IMP_plugins_output(dummy) "none"

## action simple plugins
if [info exists IMP_plugins_action_simple] { unset IMP_plugins_action_simple }
set IMP_plugins_action_simple(dummy) "none"

## action complex plugins
if [info exists IMP_plugins_action_complex] { unset IMP_plugins_action_complex }
set IMP_plugins_action_complex(dummy) "none"

## irc_event plugins
if [info exists IMP_plugins_irc_event] { unset IMP_plugins_irc_event }
set IMP_plugins_irc_event(dummy) "none"

## management plugins
if [info exists IMP_plugins_management] { unset IMP_plugins_management }
set IMP_plugins_management(dummy) "none"

##############################################################################################################################
## Load a simple plugin
proc IMP_plugin_add_simple { id match chance response language} {
  global IMP_plugins_simple plugins IMP_testing

  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_simple($id)
      putlog "IMP: ALERT! Simple plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "simple:$id"] {
    set IMP_plugins_simple($id) "${match}¦${chance}¦${response}¦${language}"
    IMP_putloglev 2 * "IMP: added simple plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin simple:$id"
}


## Find a simple plugin
proc IMP_plugin_find_simple { text lang } {
  IMP_putloglev 3 * "IMP_plugin_find_simple: text = $text, lang = $lang"
  global IMP_plugins_simple botnicks
  set s [lsort [array names IMP_plugins_simple]]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_simple($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set response [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")} {
      set rexp [IMPInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        IMP_putloglev 4 * "simple plugin $key matches"
        if {$chance > $c} {
          IMP_putloglev 4 * "  `- firing"
          return $response
        }
      }
    }
  }
  return ""
}



## Load an admin plugin
proc IMP_plugin_add_admin { id match flags callback language } {
  global IMP_plugins_admin plugins IMP_testing

  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_admin($id)
      putlog "IMP: ALERT! admin plugin $id is defined more than once"
      return 0
    }
  }

  if [IMP_plugin_check_allowed "admin:$id"] {
    set IMP_plugins_admin($id) "${match}¦${flags}¦${callback}¦${language}"
    IMP_putloglev 2 * "IMP: added admin plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin admin:$id"
}


## Find an admin plugin
proc IMP_plugin_find_admin { text lang } {
  global IMP_plugins_admin
  set s [array startsearch IMP_plugins_admin]

  while {[set key [array nextelement IMP_plugins_admin $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_admin($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set flags [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      if [regexp -nocase $rexp $text] {
        array donesearch IMP_plugins_admin $s
        return "${flags}¦$callback"
      }
    }
  }
  array donesearch IMP_plugins_admin $s
  return ""
}

## Load management plugin
proc IMP_plugin_add_management { id match flags callback { language "" } } {
  global IMP_plugins_management plugins IMP_testing

  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_management($id)
      putlog "IMP: ALERT! management plugin $id is defined more than once"
      return 0
    }
  }

  if [IMP_plugin_check_allowed "management:$id"] {
    set IMP_plugins_management($id) "${match}¦${flags}¦${callback}"
    IMP_putloglev 2 * "IMP: added management plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin management:$id"
}

## Find management plugin
proc IMP_plugin_find_management { text } {
  global IMP_plugins_management
  set s [array startsearch IMP_plugins_management]

  while {[set key [array nextelement IMP_plugins_management $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_management($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set flags [lindex $blah 1]
    set callback [lindex $blah 2]
    if [regexp -nocase $rexp $text] {
      array donesearch IMP_plugins_management $s
      return "${flags}¦$callback"
    }
  }
  array donesearch IMP_plugins_management $s
  return ""
}


## Load a complex plugin
proc IMP_plugin_add_complex { id match chance callback language } {
  global IMP_plugins_complex plugins IMP_testing
  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_complex($id)
      putlog "IMP: ALERT! Complex plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "complex:$id"] {
    set IMP_plugins_complex($id) "${match}¦${chance}¦${callback}¦${language}"
    IMP_putloglev 2 * "IMP: added complex plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin complex:$id"

}

## Find a complex plugin plugin
proc IMP_plugin_find_complex { text lang } {
  global IMP_plugins_complex botnicks
  set s [lsort [array names IMP_plugins_complex]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_complex($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any") || ($language == "all")} {
    set rexp [IMPInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        IMP_putloglev 4 * "matched complex:$key"
        if {$chance > $c} {
          lappend result $callback
        }
      }
    }
  }
  return $result
}


## Load an output plugin
proc IMP_plugin_add_output { id callback enabled language } {
  global IMP_plugins_output plugins IMP_testing

  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_output($id)
      putlog "IMP: ALERT! Output plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "output:$id"] {
    set IMP_plugins_output($id) "${callback}¦${enabled}¦$language"
    IMP_putloglev 2 * "IMP: added output plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin output:$id"
}

proc IMP_plugin_find_output { lang } {
  global IMP_plugins_output botnicks
  set s [array startsearch IMP_plugins_output]
  set result [list]

  while {[set key [array nextelement IMP_plugins_output $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_output($key)
    set blah [split $val "¦"]
    set callback [lindex $blah 0]
    set enabled [lindex $blah 1]
    set language [lindex $blah 2]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      if {$enabled == 1} {
        lappend result $callback
      }
    }
  }
  array donesearch IMP_plugins_output $s
  return $result
}


## Load a simple action plugin
proc IMP_plugin_add_action_simple { id match chance response language } {
  global IMP_plugins_action_simple plugins IMP_testing

  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_action_simple($id)
      putlog "IMP: ALERT! Simple plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "action_simple:$id"] {
    set IMP_plugins_action_simple($id) "${match}¦${chance}¦${response}¦$language"
    IMP_putloglev 2 * "IMP: added simple action plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin action_simple:$id"

}


## Find a simple action plugin
proc IMP_plugin_find_action_simple { text lang } {
  global IMP_plugins_action_simple botnicks
  set s [lsort [array names IMP_plugins_action_simple]]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_action_simple($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set response [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      set rexp [IMPInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        if {$chance > $c} {
          return $response
        }
      }
    }
  }
  return ""
}


## Load a complex action plugin
proc IMP_plugin_add_action_complex { id match chance callback language } {
  global IMP_plugins_action_complex plugins IMP_testing
  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_action_complex($id)
      putlog "IMP: ALERT! Complex action plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "action_complex:$id"] {
    set IMP_plugins_action_complex($id) "${match}¦${chance}¦${callback}¦${language}"
    IMP_putloglev 2 * "IMP: added complex action plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin action_complex:$id"

}

## Find a complex action plugin plugin
proc IMP_plugin_find_action_complex { text lang } {
  global IMP_plugins_action_complex botnicks
  set s [lsort [array names IMP_plugins_action_complex]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_action_complex($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $language $lang] || ($language == "any")|| ($language == "all")} {
      set rexp [IMPInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        IMP_putloglev 4 * "matched: $key"
        set c [rand 100]
        if {$chance > $c} {
          lappend result $callback
        }
      }
    }
  }
  return $result
}


###############################################################################

proc IMP_plugin_check_depend { depends } {

  #pass a string in the format "type:plugin,type:plugin,..."

  if {$depends == ""} {
    return 1
  }

  set result 1

  set blah [split $depends ","]
  foreach depend $blah {
    set blah2 [split $depend ":"]
    set t [lindex $blah2 0]
    set id [lindex $blah2 1]
    set a "IMP_plugins_$t"
    upvar #0 $a ar
    IMP_putloglev 1 * "IMP: checking $a for $id ..."
    set temp [array names ar $id]
    if {[llength $temp] == 0} {
      set result 0
      IMP_putloglev d * "IMP: Missing dependency $t:$id"
    }
  }
  return $result
}



###############################################################################

proc IMP_plugin_check_allowed { name } {

  #pass a string in the format "type:plugin"
  #setting in config should be "type:plugin,type:plugin,..."

  global IMPSettings

  set disallowed ""

  catch {
    set disallowed $IMPSettings(noPlugin)
  }

  if {$disallowed == ""} {
    return 1
  }

  IMP_putloglev 4 * "IMP: checking $name against $disallowed"

  set blah [split $disallowed ","]
  foreach plugin $blah {
    if {$plugin == $name} {
      return 0
    }
  }
  return 1
}

################################################################################

## dev: simsea
## Load an irc event response plugin
proc IMP_plugin_add_irc_event { id type match chance callback language } {
  if {![regexp -nocase "nick|join|quit|part|split" $type]} {
    putlog "IMP: ALERT! IRC Event plugin $id has an invalid type $type"
    return 0
  }
  global IMP_plugins_irc_event plugins IMP_testing
  if {$IMP_testing == 0} {
    catch {
      set test $IMP_plugins_irc_event($id)
      putlog "IMP: ALERT! IRC Event plugin $id is defined more than once"
      return 0
    }
  }
  if [IMP_plugin_check_allowed "irc:$id"] {
    set IMP_plugins_irc_event($id) "$type¦${match}¦$chance¦$callback¦$language"
    IMP_putloglev 2 * "IMP: added IRC event plugin: $id"
    append plugins "$id,"
    return 1
  }
  IMP_putloglev d * "IMP: ignoring disallowed plugin irc:$id"

}

## Find an IRC Event response plugin plugin
proc IMP_plugin_find_irc_event { text type lang } {
  if {![regexp -nocase "nick|join|quit|part|split" $type]} {
    putlog "IMP: IRC Event search type $type is invalid"
    return 0
  }
  global IMP_plugins_irc_event botnicks
  set s [lsort [array names IMP_plugins_irc_event]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $IMP_plugins_irc_event($key)
    set blah [split $val "¦"]
    set etype [lindex $blah 0]
    set rexp [lindex $blah 1]
    set chance [lindex $blah 2]
    set callback [lindex $blah 3]
    set language [lindex $blah 4]
    if {[string match $type $etype]} {
      if {[string match $language $lang] || ($language == "any") || ($language == "all")} {
        if [regexp -nocase $rexp $text] {
          set c [rand 100]
          if {$chance > $c} {
            lappend result $callback
          }
        }
      }
    }
  }
  return $result
}


################################################################################

## Load the simple plugins
set plugins ""
catch { source "$IMPPlugins/simple.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#IMP_putloglev d * "IMP: simple plugins loaded: $plugins"

## Load the admin plugins
set plugins ""
catch { source "$IMPPlugins/admin.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#IMP_putloglev d * "IMP: admin plugins loaded: $plugins"

## Load the complex plugins
set plugins ""
catch { source "$IMPPlugins/complex.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#IMP_putloglev d * "IMP: complex plugins loaded: $plugins"

## Load the output plugins
set plugins ""
catch { source "$IMPPlugins/output.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#IMP_putloglev d * "IMP: output plugins loaded: $plugins"

## Load the simple action plugins
catch { source "$IMPPlugins/action_simple.tcl" }

## Load the complex action plugins
catch { source "$IMPPlugins/action_complex.tcl" }

## Load the irc event plugins
catch { source "$IMPPlugins/irc_event.tcl" }

IMP_putloglev d * "Installed IMP plugins: (some may be inactive)\r"
IMP_putloglev d * "(one moment...)\r"
foreach t {simple complex admin output action_simple action_complex irc_event} {
  set arrayName "IMP_plugins_$t"
  upvar #0 $arrayName cheese
  set plugins [lsort [array names cheese]]
  set output "$t: "
  foreach n $plugins {
    if {$n != "dummy"} {
      append output "$n, "
    }
  }
  set output [string range $output 0 [expr [string length $output] - 3]]
  IMP_putloglev d * "$output\r"
}

### null plugin routine for faking plugins
proc IMP_plugin_null { {a ""} {b ""} {c ""} {d ""} {e ""} } {
  return 0
}

IMP_putloglev d * "IMP: plugins module loaded"

