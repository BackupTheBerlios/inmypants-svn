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


IMP_plugin_add_irc_event "returned" "nick" ".*" 10 "IMP_plugins_nick_returned" "en"
IMP_plugin_add_irc_event "away" "nick" "(away|sleep|gone|afk|zzz+|bed|slaap|w(o|e|3|0)rk)" 10 "IMP_plugins_nick_away" "en"

#someone's returned (fires on every nick change and checks for lack of away
proc IMP_plugins_nick_away { nick host handle channel newnick } {

  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:away" "lastnick" $channel ""]} {
    return 0
  }

  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:away" "lastnick" $channel "" $newnick

  #work
  if [regexp -nocase "w(o|e|3|0)rk" $newnick] {
    IMPDoAction $channel $nick "%VAR{awayWorks}"
    return 1
  }

  #sleep
  if [regexp -nocase "(sleep|bed|zzz+|slaap)" $newnick] {
    IMPDoAction $channel $nick "%VAR{goodnights}"
    if [IMPLike $nick $host] {
      if [rand 2] {return 0}
      IMPDoAction $channel $nick "*hugs*"
    }
    return 1
  }

  IMPDoAction $channel $nick "%VAR{cyas}"
  return 1
}


#someone's returned
proc IMP_plugins_nick_returned { nick host handle channel newnick } {

  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:returned" "lastnick" $channel ""]} {
    return 0
  }

  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:returned" "lastnick" $channel "" $newnick

  if {[regexp -nocase "(away|sleep|gone|afk|zzz+|bed|slaap|w(0|e|3|o)rk|school)" $nick] && 
       ![regexp -nocase "(away|sleep|gone|afk|slaap|w(0|e|3|o)rk|school)" $newnick]} {
    
    set IMPCache(lastDoneFor) $nick
    set IMPCache(lastGreeted) $nick

    #if they came back from sleep, it's morning
    if [regexp -nocase "(sleep|bed|zzz+|slaap)" $nick] {
      IMPDoAction $channel $newnick "%VAR{goodMornings}"
      return 1
    }

    IMPDoAction $channel $newnick "%VAR{welcomeBacks}"
    return 1
  }

  #we didn't match an away nick for their old nick, so let other nick plugins fire
  return 0
}
