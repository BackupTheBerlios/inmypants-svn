# IMP - Event handling

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

# register our counters
IMP_counter_init "events" "simpleplugins"
IMP_counter_init "events" "complexplugins"
IMP_counter_init "events" "lines"

# call an irc event response plugin
proc IMPDoEventResponse { type nick host handle channel text } {
  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  IMP_putloglev 4 * "entering IMPDoEventResponse: $type $nick $host $handle $channel $text"
  if { ![regexp -nocase "nick|join|quit|part|split" $type] } {
    return 0
  }

  global IMPInfo
  set response [IMP_plugin_find_irc_event $text $type $IMPInfo(language)]
  if {[llength $response] > 0} {
    foreach callback $response {
      IMP_flood_add $nick $callback $text
      if [IMP_flood_check $nick] { return 0 }

      IMP_putloglev 1 * "IMP: matched irc event plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $text ]
      if {$result == 1} {
        IMP_putloglev 2 * "IMP: $callback returned 1, breaking out..."
        break
      }
      return 1
    }
    return 0
  }
  return 0
}

## BEGIN onjoin handler
proc IMP_event_onjoin {nick host handle channel} {
  #ignore me
  if [isbotnick $nick] {
    return 0
  }

  #ignore the J flag users
  if [matchattr $handle J] {
    return 0
  }

  #ignore bots without the I flag
  if [matchattr $handle b-I] {
    return 0
  }

  set result [IMPDoEventResponse "join" $nick $host $handle $channel "" ]
}
## END onjoin


## BEGIN onpart handler
proc IMP_event_onpart {nick host handle channel {msg ""}} {

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  IMP_putloglev 3 * "entering imp_event_onpart: $nick $host $handle $channel $msg"
  global IMPCache

  set IMPCache(lastLeft) $nick

  #TODO: Fix this? Passing a cleaned nick around can break things
  set nick [IMP_cleanNick $nick $handle]

  set result [IMPDoEventResponse "part" $nick $host $handle $channel $msg]
}
## END onpart


## BEGIN onquit handler
proc IMP_event_onquit {nick host handle channel reason} {
  global IMPCache IMPSettings IMPInfo

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  set nick [IMP_cleanNick $nick $handle]

  set IMPCache(lastLeft) $nick

  if {$IMPInfo(brig) != ""} {
    #check if that person was in the brig
    regexp -nocase "(.+)@(.+)" $IMPInfo(brig) pop brigNick brigChannel
    if [string match -nocase $nick $brigNick] {
      set IMPInfo(brig) ""
      IMPDoAction $brigChannel "" "Curses! They escaped from the brig."
      return 0
    }
  }
  set result [IMPDoEventResponse "quit" $nick $host $handle $channel $reason ]
}
## END onquit

# BEGIN main interactive
proc IMP_event_main {nick host handle channel text} {
  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  ## Global definitions ##
  global mood botnick
  global IMPLastEvent IMPSettings botnicks IMPCache IMPInfo
  global IMPThisText IMPOriginalInput

  if [matchattr $handle J] {
    return 0
  }

  set channel [string tolower $channel]

  #ignore other bots
  if {[matchattr $handle b] && (![matchattr $handle I])} {
    set IMPCache($channel,last) 0
    return 0
  }

  if {[lsearch $IMPInfo(randomChannels) $channel] == -1} {
    return 0
  }

  IMP_putloglev 4 * "IMP: entering IMP_event_main with nick: $nick host: $host handle: $handle chan: $channel text: $text"

  set IMPOriginalInput $text

  #filter bold, etc codes out
  regsub -all "\002" $text "" text
  regsub -all "\022" $text "" text
  regsub -all "\037" $text "" text
  regsub -all "\003\[0-9\]+(,\[0-9+\])?" $text "" text

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$IMPSettings(botnicks)) ?"
  }

  #does this look like a paste?
  if [regexp -nocase {^[0-9\[<(@+%]} $text] {
    return 0
  }

  ## Update the channel idle tracker ##
  set IMPLastEvent($channel) [clock seconds]

  IMP_counter_incr "events" "lines"

  #don't let people break us
  if {![matchattr $handle n]} {
    if [regexp -nocase "%(pronoun|me|noun|colen|percent|VAR|\\|)" $text] {
      regsub -all "%" $text "%percent" text
    }
  }
  regsub -all "/" $text "%slash" text

  ## If this isn't just a smiley of some kind, trim smilies
  if {[string length $text] >= ([string length $botnick] + 4)} {
    regsub -all -nocase {[;:=]-?[)D>]} $text "" text
    regexp -all {([\-^])_*[\-^];*} $text "" text
  }

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces #
  regsub -all "  +" $text " " text

  ## Update the last-talked flag for the join system
  IMP_plugins_settings_set "system:join" "lasttalk" $channel "" 0

  set IMPThisText $text

  #if we spoke last, add "$botnick: " if it's not in the line
  if {![regexp -nocase $botnicks $text] && $IMPCache($channel,last)} {
    set text "${botnick}: $text"
  }

  #check for someone breaking the loop of lastSpoke
  if {[regexp -nocase "(i'm not talking to|not) you" $text] && $IMPCache($channel,last)} {
    IMPDoAction $channel $nick "oh"
    set IMPCache($channel,last) 0
    return 0
  }
  set IMPCache($channel,last) 0

  ## Run the simple plugins ##
  set response [IMP_plugin_find_simple $text $IMPInfo(language)]
  if {$response != ""} {
    IMP_flood_add $nick "" $text
    if [IMP_flood_check $nick] { return 0 }
    set nick [IMPGetRealName $nick $host]
    IMP_counter_incr "events" "simpleplugins"
    IMPDoAction $channel $nick [pickRandom $response]
    return 0
  }

  ## Run the complex plugins ##
  set response [IMP_plugin_find_complex $text $IMPInfo(language)]
  if {[llength $response] > 0} {
    #set nick [IMPGetRealName $nick $host]
    IMP_putloglev 1 * "going to run plugins: $response"
    foreach callback $response {
      IMP_flood_add $nick $callback $text
      if [IMP_flood_check $nick] { return 0 }

      IMP_putloglev 1 * "IMP: `- running callback $callback"
      IMP_counter_incr "events" "complexplugins"
      set result [$callback $nick $host $handle $channel $text]
      set IMPCache(lastPlugin) $callback
      if {$result == 1} {
        IMP_putloglev 2 * "IMP:    `-$callback returned 1, breaking out..."
        break
      }
    }
  }


  #Check for all caps
  regsub -all {[^A-Za-z]} $text "" textChars
  regsub -all {[a-z]} $textChars "" textLowerChars
  if {(([string length $textChars] > 4) && ([expr [string length $textLowerChars] / [string length $textChars]] > 0.9)) ||
        [regexp ".+!{4,}" $text]} {
    global blownAways
    if {[rand 60] >= 55} {
      IMPDoAction $channel $nick "%VAR{blownAways}"
      return 0
    }
  }

  ################################# Things that can be responded to from everyone ##########################

  ## Reload config files
  ## Requires global +m
  if [regexp -nocase "${botnicks},?:? re(hash|load)( your config files?)?" $text] {
    putlog "IMP: $nick asked me to rehash in $channel"
    global IMPCache IMP_testing IMPRoot

    if [matchattr $handle m] {
      #check we're not going to die
      catch {
        IMP_putloglev d * "IMP: Testing new code..."
        set IMP_testing 1
        source "$IMPRoot/IMP.tcl"
      } msg

      if {$msg != ""} {
        putlog "IMP: FATAL: Cannot rehash due to error: $msg"
        putserv "NOTICE $nick :FATAL: Cannot rehash: $msg"
        putchan $channel "A tremendous error occurred!"
        return 0
      } else {
        IMP_putloglev d * "IMP: New code ok, rehashing..."
        set IMPCache(rehash) $channel
        set IMP_testing 0
        if {[matchattr $handle m]} {
          putchan $channel [IMPDoInterpolation "%VAR{rehashes}" "" ""]
          rehash
          return 0
        }
      }
    } else {
      IMPDoAction $channel $nick "I think not."
      return 0
    }
  }
  ## /Reload config files
  # IN MY PANTS public version announcement moved to plugins/en/complex_questions.tcl
  ## ignore channels that aren't in the randoms list ##
  if {[lsearch $IMPInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  ####whole-line matches

  ## tell the names we have
  if [regexp -nocase "${botnicks}:?,? say my names?(,? bitch)?" $text] {
    set realnames [getuser $handle XTRA irl]
    if {$realnames == ""} {
      IMPDoAction $channel $nick "Ah you must be %%." "" 1
    } else {
      IMPDoAction $channel $nick "Your IRL name(s) are:\002 %2 \002" $realnames 1
    }
    puthelp "NOTICE $nick :To update your IRL names, do \002/msg $botnick IRL name1 name2 name3 ...\002"
    return 0
  }

  ###################################### +I people only ###################################################

  if {$IMPSettings(needI) == 1} {
    if {![matchattr $handle I]} {return 0}
  }

  ## shut up
  if [regexp -nocase "^${botnicks}:?,? (silence|shut up|be quiet|go away)" $text] {
    driftFriendship $nick -10
    IMPSilence $nick $host $channel
    return 0
  }

  if [regexp -nocase "(silence|shut up|be quiet|go away),?;? ${botnicks}" $text] {
    driftFriendship $nick -10
    IMPSilence $nick $host $channel
    return 0
  }
  ## /shutup

  ## This is the clever bit. If the text is "*blah blah blah*" reinject it into IMP as an action ##
  if [regexp {^\*(.+)\*$} $text blah action] {
    IMP_putloglev 1 * "Unhandled *$action* by $nick in $channel... redirecting to action handler"
    IMP_event_action $nick $host $handle $channel "" $action
    return 0
  }

}
## END main events



## BEGIN action event handler
proc IMP_event_action {nick host handle dest keyword text} {

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  global botnick mood rarrs smiles unsmiles botnicks IMPCache IMPSettings IMPInfo
  set dest [channame2dname $dest]
  set channel $dest

  if [matchattr $handle J] {
    return 0
  }

  #ignore other bots
  if {[matchattr $handle b]} {
    return 0
  }

  if {[lsearch $IMPInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  IMP_putloglev 4 * "IMP: entering IMP_event_action with $nick $host $handle $dest $keyword $text"


  set nick [IMP_cleanNick $nick $handle]

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces ##
  regsub -all "  +" $text " " text

  #ignore lines with <nobotnick> tags
  if [regexp -nocase "\</?no$botnicks\>" $text] {return 0}
  if [regexp -nocase "\<no$botnicks\>" $text] {return 0}

  #check for someone breaking the loop of lastSpoke
  if [regexp -nocase "${botnicks}:? (i'm not talking to|not) you" $text] {
    IMPDoAction $channel $nick "oh"
    set IMPCache($channel,last) 0
  }

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$IMPSettings(botnicks)) ?"
  }

  ## Run the simple plugins ##
  set response [IMP_plugin_find_action_simple $text $IMPInfo(language)]
  if {$response != ""} {
    IMP_putloglev 1 * "IMP: matched simple action plugin, outputting $response..."
    set nick [IMPGetRealName $nick $host]
    IMPDoAction $channel $nick [pickRandom $response]
    return 0
  }

  ## Run the complex plugins ##
  set response [IMP_plugin_find_action_complex $text $IMPInfo(language)]
  if {[llength $response] > 0} {
    #set nick [IMPGetRealName $nick $host]
    foreach callback $response {
      IMP_putloglev 1 * "IMP: matched complex action plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $text]
      if {$result == 1} {
        break
      }
    }
    return 0
  }

  ## LEGACY CODE STARTS HERE

  ## KatieStar ;)

  if [string match -nocase "anal sex" $text] {
    if [IMPLike $nick $host] {
      global analsexhelps
      if [rand 2] {
        IMPDoAction $channel [IMPGetRealName $nick $host] [pickRandom $analsexhelps]
      }
    }
    return 0
  }

  if [string match -nocase "wank" $text] {
    if [IMPLike $nick $host] {
      global wankhelps
      if [rand 2] {
        IMPDoAction $channel [IMPGetRealName $nick $host] [pickRandom $wankhelps]
      }

    }
    return 0
  }

#end of action handler
}

### MODE HANDLER #############################################################
proc IMP_event_mode {nick host handle channel mode victim} {

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  IMP_putloglev 4 * "IMP: entering IMP_event_mode with $nick $host $handle $channel $mode $victim"

  global botnick
	if {$victim != $botnick} {return 0}

	if {$mode == "+o"} {
	  if {$nick == ""} {return 0}

    #check to see if i was opped before
    if [wasop $botnick $channel] { return 0 }

	  IMPDoAction $channel "" "%VAR{thanks}"
		return 0
  }

	if {$mode == "-o"} {
	  IMPDoAction $channel "" "hey! %VAR{unsmiles} i needed that"
		return 0
  }
}


#someone changed nick, check for an away "msg"
proc IMP_event_nick { nick host handle channel newnick } {

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  if [matchattr $handle J] {
    return 0
  }

  set nick [IMP_cleanNick $nick $handle]
  set newnick [IMP_cleanNick $newnick $handle]

  set result [IMPDoEventResponse "nick" $nick $host $handle $channel $newnick ]
}
#end of nick handler


IMP_putloglev d * "IMP: events module loaded"
