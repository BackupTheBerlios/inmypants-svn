#IMP core
#

set IMPRoot "scripts/imp"
set IMPModules "$IMPRoot/modules"
set IMPPlugins "$IMPRoot/plugins"


if {![info exists IMP_testing]} {
  putloglev d * "IMP: IMP_testing is not defined, setting to 0."
  set IMP_testing 0
}


source "$IMPRoot/VERSION"
if {$IMP_testing == 0} {
  putlog "IMP $IMPVersion starting up..."
}


if {$IMP_testing == 1} {
  putlog "IMP: INFO: Code loading in testing mode"
  set IMP_loading 0
} else {
  putloglev 1 * "IMP: INFO: Code loading in running mode"
  set IMP_loading 1
}

foreach letter [split "d12345678" {}] {
  set IMPCache($letter,lastlog) ""
  set IMPCache($letter,lastcount) 0
}

proc IMP_putloglev { level star text } {
  global IMP_testing IMPCache
  regsub "IMP:" $text "" text
  set text2 ""
  if {$level != "d"} {
    set text2 [string repeat " " $level]
  }
  set text "IMP:$text2 $text"

  if {$IMP_testing == 0} {
    if {$IMPCache($level,lastlog) == $text} {
      incr IMPCache($level,lastcount)
      return
    }
    if {$IMPCache($level,lastcount) > 0} {
      putloglev $level $star "($level)Previous message repeated $IMPCache($level,lastcount) time(s)"
    }
    putloglev $level $star "($level)$text"
    set IMPCache($level,lastlog) $text
    set IMPCache($level,lastcount) 0
  }
}

# init default variables
if {$IMP_testing == 1} {
  putlog "... loading variables"
}
source "$IMPModules/variables.tcl"

# load counters
if {$IMP_testing == 1} {
  putlog "... loading counters"
}
source "$IMPModules/counters.tcl"

#load new abstract system
if {$IMP_testing == 1} {
  putlog "... loading abstract system"
}
source "$IMPModules/abstract.tcl"

# load abstracts file (formerly randoms)
if {$IMP_testing == 1} {
  putlog "... loading abstracts"
}
source "$IMPModules/abstracts.tcl"

# load settings
if {$IMP_testing == 1} {
  putlog "... loading settings"
}
source "$IMPModules/settings.tcl"

#try to load a file for this bot
catch {
  if {${botnet-nick} != ""} {
    source "$IMPModules/settings_${botnet-nick}.tcl"
    IMP_putloglev d * "loaded settings for this bot from settings_${botnet-nick}.tcl"
  }
}

#load system functions
if {$IMP_testing == 1} {
  putlog "... loading system"
}
source "$IMPModules/system.tcl"

# load output functions
if {$IMP_testing == 1} {
  putlog "... loading output"
}
source "$IMPModules/output.tcl"

# load mood functions
if {$IMP_testing == 1} {
  putlog "... loading mood"
}
source "$IMPModules/mood.tcl"

# load event functions
if {$IMP_testing == 1} {
  putlog "... loading events"
}
source "$IMPModules/events.tcl"

if {$IMP_testing == 1} {
  putlog "... loading events support"
}
source "$IMPModules/events_support.tcl"

# load interbot bits
if {$IMP_testing == 1} {
  putlog "... loading interbot"
}
source "$IMPModules/interbot.tcl"

# load friendship code
if {$IMP_testing == 1} {
  putlog "... loading friendship"
}
source "$IMPModules/friendship.tcl"

# load anti-flood code
if {$IMP_testing == 1} {
  putlog "... loading flood"
}
source "$IMPModules/flood.tcl"

# load queue code
if {$IMP_testing == 1} {
  putlog "... loading queue"
}
source "$IMPModules/queue.tcl"

### That's everything but the plugins stuff loaded. Now load extra modules
IMP_putloglev d * "looking for 3rd party modules..."
set files [lsort [glob -nocomplain "$IMPModules/extra/*.tcl"]]
foreach f $files {
  IMP_putloglev 1 * "loading module: $f"
  catch {
    source $f
  }
}

### Done, load the plugins:

# load plugins
if {$IMP_testing == 1} {
  putlog "... loading plugins"
}
source "$IMPModules/plugins.tcl"

if {$IMP_testing == 1} {
  putlog "... loading plugin settings"
}
source "$IMPModules/plugins_settings.tcl"

#load local abstracts
catch {
  if {${botnet-nick} != ""} {
    source "$IMPModules/abstracts_${botnet-nick}.tcl"
    IMP_putloglev d * "loaded abstracts for this bot from abstracts_${botnet-nick}.tcl"
  }
}

# load other bits
if {$IMP_testing == 1} {
  putlog "... loading leet"
}
source "$IMPModules/leet.tcl"

# load diagnostics
catch {
  if {$IMP_testing == 1} {
    putlog "... loading self-diagnostics"
  }
  source "$IMPModules/diagnostics.tcl"
}

# Ignition!

IMP_startTimers
if {$IMP_testing == 0} {
  set IMPCache(rehash) ""
  putlog "\002IMP $IMPVersion AI online\002 :D"
}

set IMP_loading 0
set IMP_testing 0

IMP_diagnostic_utimers
IMP_diagnostic_timers

# set this to 0 to stop showing the copyright
# DO NOT DISTRIBUTE THIS FILE IF THE VARIABLE IS SET TO 0
set IMP_show_copyright 1

if {$IMP_show_copyright == 1} {
  putlog "IMP is Copyright (C) 2004 Dave Wickham, apart from those parts from bMotion"
  putlog "bMotion is Copyright (C) 2002-2004 James Seward. IMP comes with ABSOLUTELY NO WARRANTY;"
  putlog "This is free software, and you are welcome to redistribute it under certain conditions."
  putlog "See the COPYRIGHT file for details. You can edit IMP.tcl to hide this message once you have read it."
}
