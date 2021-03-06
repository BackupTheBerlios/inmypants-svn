## IMP complex plugin: hello

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

IMP_plugin_add_complex "hello" "^(hey|hi|hello|r|greetings|hullo|bonjour|morning|afternoon|evening|yo|y0) %botnicks(!)?$" 100 IMP_plugin_complex_hello "en"
IMP_plugin_add_complex "hello2" "^%botnicks(!+|\[!\"�\$%^&*()#\]{3,})" 100 IMP_plugin_complex_hello "en"

proc IMP_plugin_complex_hello { nick host handle channel text } {
  global botnicks
  set exclaim ""
  regexp -nocase "^${botnicks}(!+|\[!\"�\$%^&*()#\]{3,})" $text bling pop exclaim
  global IMPInfo IMPCache

  set lastGreeted [IMP_plugins_settings_get "complex:hello" "lastGreeted" $channel ""]

  if {$IMPInfo(away) == 1} {
    putserv "AWAY"
    set IMPInfo(away) 0
    set IMPInfo(silence) 0
    IMPDoAction $channel "" "/returns"
  }

  driftFriendship $handle 3

  #check if this nick has already been greeted
  if {$lastGreeted == $handle} {
    IMPDoAction $channel "" "%VAR{smiles}"
    return 1
  }

  IMP_plugins_settings_set "complex:hello" "lastGreeted" $channel "" $handle

  if {[string length $exclaim] >= 3} {
    set greeting "%%%colen"
  } else {
    if {[getFriendship $nick] > 60} {
      set greeting "%VAR{hello_familiars}"
    } else {
      set greeting "%VAR{greetings}"
    }
  }

  # get random nick from realnames
  set nick [IMPGetRealName $nick]

  IMPDoAction $channel $nick $greeting
  return 1
}

set hello_familiars {
  "%%%colen"
  "%%!"
  "%% :D"
  "%% ^_^"
  "/hugs %%"
}
