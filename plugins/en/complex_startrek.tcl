## Startrek stuff plugin for IMP

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

IMP_plugin_add_complex "st-cloak" "^%botnicks cloak$" 100 "IMP_plugin_complex_startrek_cloak" "en"
IMP_plugin_add_complex "st-decloak" "^%botnicks decloak$" 100 "IMP_plugin_complex_startrek_decloak" "en"
IMP_plugin_add_complex "st-fire" "^%botnicks fire " 100 "IMP_plugin_complex_startrek_fire" "en"
IMP_plugin_add_complex "st-courtmartial" "^%botnicks courtmartial " 100 "IMP_plugin_complex_startrek_courtmartial" "en"

#change the last value in the line below to 1 to make a guilty person get kicked
#and to 0 to not kick (SECURITY IMPLICATIONS!)
IMP_plugins_settings_set "complex:startrek" "kick" "active" "" "0"

#this is the kick message used
IMP_plugins_settings_set "complex:startrek" "kick" "message" "" "Guilty!"

#cloak
proc IMP_plugin_complex_startrek_cloak { nick host handle channel text } {
  global IMPInfo
  if {$IMPInfo(cloaked) == 1} {
    IMPDoAction $channel $nick "Already running cloaked, sir"
    return 1
  }
  set IMPInfo(cloaked) 1
  IMPDoAction $channel $nick "/shimmers and disappears from view..."
  return 1
}

#decloak
proc IMP_plugin_complex_startrek_decloak { nick host handle channel text } {
  global IMPInfo
  if {$IMPInfo(cloaked) == 0} {
    IMPDoAction $channel "" "Already decloaked, sir"
    return 1
  }
  set IMPInfo(cloaked) 0
  IMPDoAction $channel $nick "/shifts back into view"
  return 1
}

#fire
proc IMP_plugin_complex_startrek_fire { nick host handle channel text } {
  global botnicks IMPInfo
  if [regexp -nocase "$botnicks fire (.+) at (.+)" $text pop frogs weapon target] {
    set weapon [string tolower $weapon]
    if {![regexp "(phasers|torpedoe?|photon|quantum|cheesecake|everything)" $weapon]} {
      if {[string range $weapon [expr [string length $weapon] - 1] end] == "s"} {
        IMPDoAction $channel $nick "I haven't got any '$weapon' ... I think they %VAR{fellOffs}."
      } else {
        IMPDoAction $channel $nick "I haven't got any '$weapon' ... I think it %VAR{fellOffs}."
      }
      return 1
    }

    if [regexp -nocase $botnicks $target] {
      IMPDoAction $channel $nick "Don't be so silly. Sir."
      return 1
    }

    if {$IMPInfo(cloaked) == 1} {
      IMPDoAction $channel "" "/swoops in on $target, decloaking on the way..."
    } else {
      IMPDoAction $channel "" "/swoops in on $target"
    }
    
    if {$weapon == "phasers"} {
      global phaserFires
      IMPDoAction $channel $target "%VAR{phaserFires}"
    }

    if [regexp "(torpedoe?s|photon|quantum)" $weapon] {
      global torpedoFires
      IMPDoAction $channel $target "%VAR{torpedoFires}"
    }

    if {$weapon == "everything"} {
      global everythingFires
      IMPDoAction $channel $target "%VAR{everythingFires}"
    }

    if {$IMPInfo(cloaked) == 1} {
      IMPDoAction $channel "" "/recloaks"
    }
    return 1
  }
}

proc IMP_plugin_complex_startrek_courtmartial { nick host handle channel text } {
  global botnicks IMPInfo
  if [regexp -nocase "$botnicks courtmartial (.+?)( with banzai)?" $text pop frogs who banzai] {
    if [regexp -nocase "\[\[:<:\]\]$botnicks\[\[:>:\]\]" $who] {
      IMPDoAction $channel "" "Duh."
      return 0
    }

    if {$banzai != ""} { set IMPInfo(banzaiModeBrig) 1 } else { set IMPInfo(banzaiModeBrig) 0 }

    if {$IMPInfo(brig) != ""} {
      IMPDoAction $channel $nick "I'm sorry Sir, I already have someone in the brig - please try again later, or empty the Recycle Bin."
      return 0
    }

    if {![onchan $who $channel]} {
      IMPDoAction $channel "" "Who?"
      puthelp "NOTICE $nick :Please specify the full nickname of someone in the channel (Couldn't find '$who')."
      return 0
    }

    set IMPInfo(brig) "$who@$channel"
    if {$IMPInfo(banzaiModeBrig) == 1} {
      global brigBanzais
      set banzaiName [pickRandom $brigBanzais]
      IMPDoAction $channel $who $banzaiName
      IMPDoAction $channel $who "Rules simple. Simply decide if you think I'll find %% innocent."
      set IMPInfo(brigInnocent) [list]
      set IMPInfo(brigGuilty) [list]
      bind pub - "!vote" IMPVoteHandler
      IMPDoAction $channel $who "Place bets now!"
    }
    IMPDoAction $channel $who "/throws %% in the brig to await charges"
    utimer $IMPInfo(brigDelay) IMPDoBrig
    if {$IMPInfo(banzaiModeBrig) == 1} {
      utimer [expr $IMPInfo(brigDelay) / 2 + 7] IMPBanzaiBrigMidBet
    }
    return 0
  }
}


### Supporting functions
proc IMPBanzaiBrigMidBet {} {
  global IMPInfo banzaiMidBets

  set brigInfo $IMPInfo(brig)
  if {$brigInfo == ""} { return 0 }
  regexp -nocase "(.+)@(.+)" $brigInfo pop nick channel

  IMPDoAction $channel "" [pickRandom $banzaiMidBets]
  return 0  
}

proc IMPDoBrig {} {
  global IMPInfo charges trekNouns punishments

  set brigInfo $IMPInfo(brig)
  if {$brigInfo == ""} { return 0 }
  regexp -nocase "(.+)@(.+)" $brigInfo pop nick channel

  if {![onchan $nick $channel]} {
    putlog "IMP: Was trying to courtmartial $nick on $channel, but they're not there no more :("
    set IMPInfo(brig) ""
    return 0
  }

  if {$IMPInfo(banzaiModeBrig) == 1} {
    IMPDoAction $channel "" "Betting ends!"
  }

  set charge "%%, you are charged with [IMPInsertString [pickRandom $charges] %% [pickRandom $trekNouns]], and [IMPInsertString [pickRandom $charges] %% [pickRandom $trekNouns]]"
  IMPDoAction $channel $nick $charge
  set IMPInfo(brig) ""

  set guilty [rand 2]
  if {$guilty} {
    IMPDoAction $channel [pickRandom $trekNouns] "You have been found guilty, and are sentenced to [pickRandom $punishments]. And may God have mercy on your soul."
    if {$IMPInfo(banzaiModeBrig) == 1} {
      if {[llength $IMPInfo(brigGuilty)] > 0} {
        IMPDoAction $channel $IMPInfo(brigGuilty) "Congraturation go to big winner who are %%. Well done! Riches beyond your wildest dreams are yours to taking!"
      }
      if {[IMP_plugins_settings_get "complex:startrek" "kick" "active" ""] == 1} {
        set msg [IMP_plugins_settings_set "complex:startrek" "kick" "message" ""]
        puthelp "KICK $channel $nick :$message"
      }
    }
  } else {
    IMPDoAction $channel "" "You have been found innocent, have a nice day."
    if {$IMPInfo(banzaiModeBrig) == 1} {
      if {[llength $IMPInfo(brigInnocent)] > 0} {
        IMPDoAction $channel $IMPInfo(brigInnocent) "Congraturation go to big winner who are %%. Well done! Glory and fame are yours!"
      }
    }
  }

  if {$IMPInfo(banzaiModeBrig) == 1} {
    set IMPInfo(banzaiModeBrig) 0
  }
  return 0
}

proc IMPVoteHandler {nick host handle channel text} {
  global IMPInfo
  set brigInfo $IMPInfo(brig)
  if {$brigInfo == ""} { 
    #unbind    
    putlog "IMP: Oops, need to unbind votes"
    unbind pubm - "!vote" IMPVoteHandler
    return 0 
  }

  if {[lsearch $IMPInfo(brigInnocent) $nick] != -1} {
    puthelp "NOTICE $nick :You have already voted."
    return 0
  }

  if {[lsearch $IMPInfo(brigGuilty) $nick] != -1} {
    puthelp "NOTICE $nick :You have already voted."
    return 0
  }

  if [string match -nocase "innocent" $text] {    
    lappend IMPInfo(brigInnocent) $nick
    putlog "IMP: Accepted innocent vote from $nick"
    return 0
  }

  if [string match -nocase "guilty" $text] {
    lappend IMPInfo(brigGuilty) $nick
    putlog "IMP: Accepted guilty vote from $nick"
    return 0
  }
  puthelp "NOTICE $nick: Syntax: !vote <guilty|innocent>"
}
