###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


proc IMP_plugins_irc_default_quit { nick host handle channel text } { 

  #has something happened since we last spoke?
  set lasttalk [IMP_plugins_settings_get "system:join" "lasttalk" $channel ""]

  if {$handle == "*"} {
    if {[IMP_setting_get "friendly"] != 1} {
      return 0
    }
  }

  #don't do anything if it looks like an error
  if [regexp -nocase "(error|reset|timeout|closed)" $text] {
    return 0
  }

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    #IMP_putloglev 2 d "dropping depart for $nick on $channel because it's too idle"
    putlog "dropping depart for $nick on $channel because it's too idle"
    return 0
  }

  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{departs}"
  set IMPCache(lastGreeted) $nick
  IMP_plugins_settings_set "system:join" "lasttalk" $channel "" 1

  return 0
}

IMP_plugin_add_irc_event "default quit" "quit" ".*" 15 "IMP_plugins_irc_default_quit" "en"
IMP_plugin_add_irc_event "default part" "part" ".*" 15 "IMP_plugins_irc_default_quit" "en"

IMP_abstract_register "departs"
IMP_abstract_batchadd "departs" [list "what a strange person" "i'm going to miss them" "nooo! come back! %VAR{unsmiles}" "hey! I was talking to you!" "what a nice man"]
