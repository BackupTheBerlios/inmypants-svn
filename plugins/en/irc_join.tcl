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


proc IMP_plugins_irc_default_join { nick host handle channel text } { 

  global IMPCache

  #has something happened since we last greeted?
  set lasttalk [IMP_plugins_settings_get "system:join" "lasttalk" $channel ""]

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    IMP_putloglev 2 d "dropping greeting for $nick on $channel because it's too idle"
    return 0
  }

  global botnick mood
  set chance [rand 10]

  set greetings [IMP_abstract_all "ranjoins"]

  if {$handle != "*"} {
    set greetings [concat $greetings [IMP_abstract_all "insult_joins"]]
    if {$nick == $IMPCache(lastLeft)} {
      set greetings [IMP_abstract_all "welcomeBacks"]
      set IMPCache(lastLeft) ""
    }
    IMPGetHappy
    IMPGetUnLonely
  } else {
    #don't greet people we don't know
    if {[IMP_setting_get "friendly"] != 1} {
      return 0
    }
  }

  #set nick [IMP_cleanNick $nick $handle]
  if {[getFriendship $nick] < 30} {
    set greetings [IMP_abstract_all "dislike_joins"]
  }

  if {[getFriendship $nick] > 75} {
    set greetings [concat $greetings [IMP_abstract_all "bigranjoins"]]
  }

  IMPDoAction $channel [IMPGetRealName $nick $host] [pickRandom $greetings]
  set IMPCache(lastGreeted) $nick
  IMP_plugins_settings_set "system:join" "lasttalk" $channel "" 1

  return 0
}

IMP_plugin_add_irc_event "default join" "join" ".*" 40 "IMP_plugins_irc_default_join" "en"

IMP_abstract_register "insult_joins"
IMP_abstract_batchadd "insult_joins" [list "%ruser: yeah, %% does suckOH HI %%!" "\[%%\] I'm a %VAR{PROM}%|%VAR{wrong_infoline}" "\[%%\] I love %ruser%|%VAR{wrong_infoline}"]

IMP_abstract_register "wrong_infoline"
IMP_abstract_batchadd "wrong_infoline" [list "oops, wrong infoline, sorry" "huk, wrong infoline" "whoops" "o wait not that infoline"]

IMP_abstract_register "dislike_joins"
IMP_abstract_batchadd "dislike_joins" [list "shut up" "o no it's %%" "oh no it's %%" "oh noes it's %% %VAR{unsmiles}"]
bMot
