# IMP admin plugins

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#                        name   regexp               flags   callback
IMP_plugin_add_admin "test" "^test"              n       "IMP_plugin_admin_test" "any"
IMP_plugin_add_admin "status" "^(status|info)"     t       "IMP_plugin_admin_status" "any"
IMP_plugin_add_admin "queue" "^queue"            n       "IMP_plugin_admin_queue" "any"
IMP_plugin_add_admin "parse" "^parse"            n       "IMP_plugin_admin_parse" "any"
IMP_plugin_add_admin "friends" "^friends(hip)?"  n       "IMP_plugin_admin_friends" "any"
IMP_plugin_add_admin "unbind votes" "^unbind votes" n    "IMP_plugin_admin_unbindVotes" "any"
IMP_plugin_add_admin "codesize" "^codesize"          n       "IMP_plugin_admin_codesize" "any"
IMP_plugin_add_admin "rehash" "^rehash"          n       "IMP_plugin_admin_rehash" "any"
IMP_plugin_add_admin "reload" "^reload"          n       "IMP_plugin_admin_reload" "any"
IMP_plugin_add_admin "settings_clear" "^settings clear" n IMP_plugin_admin_settings_clear "any"

#################################################################################################################################
# Declare plugin functions

proc IMP_plugin_admin_test { handle idx args } {
  putidx $idx "test: $handle $args"
}

proc IMP_plugin_admin_status { handle idx args } {
  global IMPInfo botnicks IMPSettings IMPVersion randomsinfo IMPQueue
  set timezone [clock format [clock seconds] -format "%Z"]

  putidx $idx "I am running IMP $IMPVersion\r"
  putidx $idx "Using randoms file $randomsinfo\r"
  putidx $idx "My gender is $IMPInfo(gender), and I am $IMPInfo(orientation)\r"
  putidx $idx "Respond to everything is $IMPInfo(balefire) (1 = on)\r"
  putidx $idx "Current pokemon is $IMPInfo(pokemon)\r"
  putidx $idx "Random stuff happens at least every $IMPInfo(minRandomDelay), at most every $IMPInfo(maxRandomDelay), and not if channel quiet for more than $IMPInfo(maxIdleGap) (mins)\r"
  putidx $idx "My botnicks are $botnicks ('.imp redo botnicks' to update)\r"
  putidx $idx "melMode $IMPSettings(melMode) (1 = on)\r"
  putidx $idx "needI $IMPSettings(needI) (1 = on)\r"
  if {$IMPInfo(silence)} { putidx $idx "Running silent\r" }    
  putidx $idx "Current queue size is [llength $IMPQueue]\r"
  return 0
}

proc IMP_plugin_admin_queue { handle idx { args "" }} {
  global IMPQueue

  if {$args == ""} {
    #display queue
    putidx $idx "Queue size: [llength $IMPQueue]\r";
    set i 0
    foreach item $IMPQueue {
      putidx $idx "$i: $item\r"
      incr i
    }
    return 0
  }

  if [regexp -nocase "clear|flush|delete|reset" $args] {
    putidx $idx "Flushing queue...\r";
    global IMPQueue
    set IMPQueue [list]
    return 0
  }
}

proc IMP_plugin_admin_parse { handle idx arg } {
  if [regexp -nocase {(\[#!\][^ ]+)( (.+))} $arg matches channel pom txt] {
    IMPDoAction $channel "" $txt
    putlog "IMP: Parsed text from DCC chat"
  }
}

proc IMP_plugin_admin_friends { handle idx { arg "" } } {
  if {$arg == ""} {
    putidx $idx "[getFriendsList]\r"
    return 0
  }

  if [regexp -nocase {([^ ]+)( (.+))?} $arg matches nick pom val] {
    if {$val == ""} {
      putidx $idx "friendship rating for $nick is [getFriendshipHandle $nick]\r"
    } else {
      setFriendshipHandle $nick $val
      putidx $idx "friendship rating for $nick is now [getFriendshipHandle $nick]\r"
    }
    return 0
  }
}

proc IMP_plugin_admin_unbindVotes { handle idx arg } {
  putidx $idx "Unbinding vote commands...\r"
  unbind pub - "!innocent" IMPVoteHandler
  unbind pub - "!guilty" IMPVoteHandler
  unbind pubm - "!innocent" IMPVoteHandler
  unbind pubm - "!guilty" IMPVoteHandler
  putidx $idx "ok\r"
}


proc IMP_plugin_admin_codesize { handle idx { arg "" } } {
  #get codesize for IMP
  
  global IMPRoot IMPModules IMPPlugins
  set scriptName "[pwd]/$IMPRoot/codeSize"

  #check the script is present and executable
  if {![file exists $scriptName]} {
    putidx $idx "IMP: ERROR: Can't find supporting script $scriptName!"
    return 0
  }

  if {![file executable $scriptName]} {
    putidx $idx "IMP: ERROR: $scriptName is not executable :("
    return 0
  }

  IMP_putloglev 2 * "IMP: codeSize script is $scriptName"
  
  set modules_output [exec $scriptName $IMPModules]
  set plugins_output [exec $scriptName $IMPPlugins]
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ total} $modules_output matches modules
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ total} $plugins_output matches plugins
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ .+IMP\.tcl} [exec wc $IMPRoot/IMP.tcl] matches loader

  set total [expr $modules + $plugins + $loader]

  putidx $idx "IMP: codesize: $loader in stub, $modules in modules, $plugins in plugins, $total in total\r"
  return 0
}

proc IMP_plugin_admin_rehash { handle idx { arg "" } } {
  global IMPCache IMP_testing IMPRoot

  #check we're not going to die
  catch {
    IMP_putloglev d * "IMP: Testing new code..."
    set IMP_testing 1
    source "$IMPRoot/IMP.tcl"
  } msg

  if {$msg != ""} {
    putlog "IMP: FATAL: Cannot rehash due to error: $msg"
    return 0
  } else {
    IMP_putloglev d * "IMP: New code ok, rehashing..."
    set IMP_testing 0
    rehash
  }
}

proc IMP_plugin_admin_reload { handle idx { arg "" } } {
  global IMPCache IMP_testing IMPRoot

  #check we're not going to die
  catch {
    IMP_putloglev d * "IMP: Testing new code..."
    set IMP_testing 1
    source "$IMPRoot/IMP.tcl"
  } msg

  if {$msg != ""} {
    putlog "IMP: FATAL: Cannot reload due to error: $msg"
    return 0
  } else {
    IMP_putloglev d * "IMP: New code ok, reloading..."
    set IMP_testing 0
    source "$IMPRoot/IMP.tcl"
  }
}

proc IMP_plugin_admin_settings_clear { handle idx { arg "" } } {
  global IMP_plugins_settings
  if {![info exists IMP_plguins_settings]} {
    unset IMP_plugins_settings
    set IMP_plugins_settings(dummy,setting,channel,nick) "dummy"
  }
  putidx $idx "Cleared plugins settings array\r"
}
