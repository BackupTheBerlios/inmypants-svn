## IMP complex plugin: hands

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

IMP_plugin_add_action_complex "hands" "(hands|gives) %botnicks " 100 IMP_plugin_complex_action_hands "en"

proc IMP_plugin_complex_action_hands { nick host handle channel text } {
  global botnicks
	if {[regexp -nocase "(hands|gives) $botnicks (a|an|the|some)? (.+)" $text bling act bot preposition item]} {
	  IMP_putloglev d * "IMP: Got handed !$item! by $nick in $channel"

    #Coffee
		if [regexp -nocase "(cup of )?coffee" $item] {
      IMP_plugin_complex_action_hands_coffee $channel $nick
      return 1
		}

    #hug
    if [regexp -nocase "^hug" $item] {
      if [IMP_plugin_check_depend "action_complex:hugs"] {
        IMP_plugin_complex_action_hugs $nick $host $handle $channel ""
        return 1
      }
    }

    # Tissues
    if [regexp -nocase "((box of)|a)? tissues?" $item] {
      IMP_plugin_complex_action_hands_tissues $channel $nick
      return 1
    }

    # Body paint
    if [regexp -nocase "(chocolate|strawberry) (sauce|bodypaint|body paint|body-paint)" $item] {
      IMP_plugin_complex_action_hands_bodypaint $channel $nick
      return 1
    }

    # pie
    if [regexp -nocase "pie" $item] {
      IMP_plugin_complex_action_hands_pie $channel $nick
      return 1
    }

    #spliff
    if [regexp -nocase "(spliff|joint|bong|pipe|dope|gear|pot)" $item] {
      IMP_plugin_complex_action_hands_spliff $channel $nick $handle
      return 1
    }

    #dildo
    if [regexp -nocase "(dildo|vibrator|cucumber|banana|flute)" $item bling item2] {
      IMP_plugin_complex_action_hands_dildo $channel $nick $item $item2
      return 1
    } 
    #end of "hands dildo"

    #catch everything else
    IMPDoAction $channel $item "%VAR{hand_generic}"
    
    #we'll add it to our random things list for this session too
    IMP_abstract_add "sillyThings" $item
    return 1
  } 
  #end of "hands" handler
}


# supporting functions

##### COFFEE
proc IMP_plugin_complex_action_hands_coffee { channel nick } {
  global got
  set coffeeNick [IMP_plugins_settings_get "complexaction:hands" "coffee_nick"  "" ""]
  IMP_putloglev 1 * "IMP: ...and it's a cup of coffee... mmmmmmm"
  if {$coffeeNick != ""} {
    IMP_putloglev 1 * "IMP: But I already have one :/"
    IMPDoAction $channel $nick "%%: thanks anyway, but I'm already drinking the one $coffeeNick gave me :)"
    return 1
  }
  driftFriendship $nick 2
  IMPDoAction $channel "" "%VAR{thanks}"
  IMPDoAction $channel "" "mmmmm..."
  IMPDoAction $channel "" "/drinks the coffee %VAR{smiles}"
  IMP_plugins_settings_set "complexaction:hands" "coffee_nick" "" "" $nick
  IMP_plugins_settings_set "complexaction:hands" "coffee_channel" "" "" $channel
  utimer 45 { IMP_plugin_complex_action_hands_finishcoffee }
  return 1
}

proc IMP_plugin_complex_action_hands_finishcoffee { } {
  global mood
  set coffeeChannel [IMP_plugins_settings_get "complexaction:hands" "coffee_channel" "" ""]
	IMPDoAction $coffeeChannel "" "/finishes the coffee"
	IMPDoAction $coffeeChannel "" "mmmm... thanks :)"
  incr mood(happy) 1
	IMP_plugins_settings_set "complexaction:hands" "coffee_nick" "" "" ""
}


##### TISSUES

proc IMP_plugin_complex_action_hands_tissues { channel nick } {
  IMP_putloglev 1 * "IMP: ...and it's a box of tissues! ~rarr~"
  global mood
  if {$mood(horny) < -3} {
    IMP_putloglev 1 * "IMP: But i'm not in the mood"
    IMPDoAction $channel "" "$nick: thanks, but i'm not in the mood for that right now :("
  }

  set tissuesNick [IMP_plugins_settings_get "complexaction:hands" "tissues_nick" "" ""]
  if {$tissuesNick != ""} {
    IMP_putloglev 1 * "IMP: But I already have one :/"
    IMPDoAction $channel "" "$nick: thanks anyway, but I'm already using the tissues $tissuesNick gave me :) *uNF*"
  }

  driftFriendship $nick 2
  IMPDoAction $channel "" "%VAR{thanks}"
  IMPDoAction $channel $nick "/locks %himherself in the bathroom"
  IMP_plugins_settings_set "complexaction:hands" "tissues_nick" "" "" $nick
  IMP_plugins_settings_set "complexaction:hands" "tissues_channel" "" "" $channel

  #TODO: this mood stuff is OLD
  incr mood(lonely) -1
  incr mood(horny) -1
  incr mood(happy) 2

  utimer 90 IMP_plugin_complex_action_hands_finishtissues
}

proc IMP_plugin_complex_action_hands_finishtissues { } {
  global mood
  set tissuesChannel [IMP_plugins_settings_get "complexaction:hands" "tissues_channel" "" ""]
  IMPDoAction $tissuesChannel "" "uNF *squeaky* *boing* *squirt*"
  IMPDoAction $tissuesChannel "" "/finishes using the tissues"
  IMP_plugins_settings_set "complexaction:hands" "tissues_nick" "" "" ""

  #TODO: this mood stuff is OLD
  incr mood(happy) 1
  incr mood(horny) -2
}


###### BODY PAINT

proc IMP_plugin_complex_action_hands_bodypaint { channel nick } {
  IMP_putloglev 1 *  "IMP: Ooh ooh body paint!"
  if {![IMPLike $nick]} {
    frightened $nick $channel
    return 0
  }

  global IMPInfo
  driftFriendship $nick 2
  if {$IMPInfo(gender) == "male"} {
    IMPDoAction $channel $nick "/applies it to %%"
    IMPDoAction $channel $nick "/licks it off"
    return 0
  }

  #female
  set bodyPaintNick [IMP_plugins_settings_get "complexaction:hands" "paint_nick" "" ""]

  if {$bodyPaintNick != ""} {
    IMP_putloglev 1 * "IMP: But I'm already wearing some"
    IMPDoAction $channel $bodyPaintNick "Thanks $nick but I'm already waiting for %% to lick some body paint off me"
    return 0
  }

  IMPDoAction $channel $nick "/smears it over herself and waits for %% to come and lick it off"
  IMP_plugins_settings_set "complexaction:hands" "paint_nick" "" "" $nick
  IMP_plugins_settings_set "complexaction:hands" "paint_channel" "" "" $channel
  utimer 60 IMP_plugin_complex_action_hands_finishPaint
  return 0
}

proc IMP_plugin_complex_action_hands_finishPaint { } {
  set bodyPaintNick [IMP_plugins_settings_get "complexaction:hands" "paint_nick" "" ""]
  set bodyPaintChannel [IMP_plugins_settings_get "complexaction:hands" "paint_channel" "" ""]
  IMPDoAction $bodyPaintChannel $bodyPaintNick "/gets bored of waiting for %% and licks the body paint off by herself instead"
  IMP_plugins_settings_set "complexaction:hands" "paint_nick" "" "" ""
  IMPGetHorny
  IMPGetLonely
}

##### PIE

proc IMP_plugin_complex_action_hands_pie { channel nick } {
  driftFriendship $nick 1
  IMP_putloglev 1 * "IMP: ah ha, pie :D"
  IMPGetHappy
  IMPGetUnLonely
  IMPDoAction $channel $nick ":D%|thanks %%%|/eats pie"
  return 0
}

##### SPLIFF

proc IMP_plugin_complex_action_hands_spliff { channel nick handle } {
  global mood

  driftFriendship $nick 1
  IMP_putloglev 1 * "IMP: ... and it's mind-altering drugs! WOOHOO!"
  IMP_putloglev 1 * "IMP: ...... wheeeeeeeeeeeeeeeeeeeeeeeeeeeeeee...."
  incr mood(stoned) 2
  checkmood $nick $channel
  IMPDoAction $channel $nick "%VAR{smokes}"
  return 0
}

# abstracts
set hand_generic {
  "%VAR{thanks}"
  "%REPEAT{3:6:m} %%"
  "Do I want this?"
  "Just what I've always wanted %VAR{smiles}"
}
