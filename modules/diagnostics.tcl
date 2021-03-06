# IMP - Diagnostics

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

#
# Check if a channel has uppercase letters in it
#
proc IMP_diagnostic_channel1 { } {
  global IMPInfo

  set err 0
  set cleanChannels [list]
  foreach chan $IMPInfo(randomChannels) {
    set chan2 [string tolower $chan]
    if {$chan != $chan2} {
      #case difference
      set err 1
    }
    lappend cleanChannels $chan2
  }
  set IMPInfo(randomChannels) $cleanChannels

  if {$err == 1} {
    putlog "Self-diagnostics indicate you have a channel with a captial letter in in your settings file."
    putlog "  This has been fixed on the fly at load time, but you will need to edit the settings file"
    putlog "  to prevent this reoccuring. Please use all lower-case characters for defining channels."
  }
}

#
# Check the bot's configured for all the channels in the list
proc IMP_diagnostic_channel2 { } {
  global IMPInfo

  set notOnChans ""
  set botChans [list]
  foreach chan [channels] {
    lappend botChans [string tolower $chan]
  }

  foreach chan $IMPInfo(randomChannels) {
    if {[lsearch -exact $botChans $chan] < 0} {
      #configured chan the bot doesn't know about
      append notOnChans "$chan "
    }
  }
  if {$notOnChans != ""} {
    putlog "The following channels are in the settings file, but not configured in eggdrop (typos?): $notOnChans"
  }
}

#
# make sure we only have one instance of each timer
proc IMP_diagnostic_timers { } {
  IMP_putloglev d * "running level 4 diagnostic on timers"
  set alltimers [timers]
  set seentimers [list]
  foreach t $alltimers {
    IMP_putloglev 1 * "checking timer $t"
    set t_function [lindex $t 1]
    set t_name [lindex $t 2]
    set t_function [string tolower $t_function]
    if {[lsearch $seentimers $t_function] >= 0} {
      putlog "IMP: A level 4 diagnostic has found a duplicate timer $t_name for $t_function ... removing"
      #remove timer
      killtimer $t_name
    } else {
      #add to seen list
      lappend seentimers $t_function
    }
  }
}

#
# make sure we have only one instance of each utimer
proc IMP_diagnostic_utimers { } {
  IMP_putloglev d * "running level 4 diagnostic on utimers"
  set alltimers [utimers]
  set seentimers [list]
  foreach t $alltimers {
    IMP_putloglev 1 * "checking timer $t"
    set t_function [lindex $t 1]
    set t_name [lindex $t 2]
    set t_function [string tolower $t_function]
    if {[lsearch $seentimers $t_function] >= 0} {
      putlog "IMP: A level 4 diagnostic has found a duplicate utimer $t_name for $t_function ... removing"
      #remove timer
      killutimer $t_name
    } else {
      #add to seen list
      lappend seentimers $t_function
    }
  }
}

proc IMP_diagnostic_auto { min hr a b c } {
  putlog "IMP: running level 4 self-diagnostic"
  IMP_diagnostic_timers
  IMP_diagnostic_utimers
}

IMP_putloglev d * "Running a level 5 self-diagnostic..."

IMP_diagnostic_channel1
IMP_diagnostic_channel2

IMP_putloglev d * "Diagnostics complete."

bind time - "30 * * * *" IMP_diagnostic_auto
