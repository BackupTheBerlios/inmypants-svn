## IMP plugin: away handler
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

IMP_plugin_add_action_complex "away" "^(is )?away" 40 IMP_plugin_complex_action_away "en"
IMP_plugin_add_action_complex "back" "^((is )?back)|(has returned)" 40 IMP_plugin_complex_action_back "en"

# abstracts
IMP_abstract_register "goodnights"
IMP_abstract_register "cyas"
IMP_abstract_register "welcomeBacks"
IMP_abstract_register "joinins"
IMP_abstract_register "goodMornings"
IMP_abstract_register "autoAways"
IMP_abstract_register "awayWorks"
IMP_abstract_register "goodlucks"

proc IMP_plugin_complex_action_away { nick host handle channel text } {

  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:away" "lastnick" $channel ""]} {
    return 1
  }

  if {![IMP_interbot_me_next $channel]} {
    return 0
  }

  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:away" "lastnick" $channel "" $nick
  
  #autoaway
  if [regexp -nocase "(auto( |-)?away|idle)" $text] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{autoAways}"
    return 1
  }

  #work
  if [regexp -nocase "w(o|0|e|3)rk" $text] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{awayWorks}"
    return 1
  }

  #sleep
  if [regexp -nocase "(sleep|regenerating|bed|zzz)" $text] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{goodnights}"
    if [IMPLike $nick $host] {
      if [rand 2] {return 1}
      IMPDoAction $channel [IMPGetRealName $nick $host] "*hugs*"
    }
    return 1
  }

  #shower
  if [regexp -nocase "(shower|nekkid)" $text] {
    if [IMPLike $nick $host] {
      IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{joinins}"
      IMPGetHorny
      return 1
    }
  }

  #exam
  if [regexp -nocase "exam" $text] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{goodlucks}"
    return 1
  }
    
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{cyas}"
  return 1
}

proc IMP_plugin_complex_action_back { nick host handle channel text } {

  if {![IMP_interbot_me_next $channel]} { return 0 }

  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:returned" "lastnick" $channel ""]} {
    return 1
  }

  if {![IMP_interbot_me_next $channel]} {
    return 1
  }

  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:returned" "lastnick" $channel "" $nick

  #let's do some cool stuff
  #if they came back from sleep, it's morning
  if [regexp -nocase "(sleep|regenerating|bed|zzz)" $text] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{goodMornings}"
    return 1
  }

  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{welcomeBacks}"
  }
  set IMPCache(lastGreeted) $nick
  return 0
}

