# IMP - interbot stuff
#

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

# Elect a new bot to speak for each channel
proc IMP_interbot_next_elect { } {
  #send a message to all the bots on each of my channels
  # I pick a number and send it
  # This makes them all pick a number too and send that as a reply to all the other bots too
  # Each bot tracks the numbers, highest bot wins and speaks next

  global IMPInfo IMP_interbot_timer
  catch {
    foreach chan $IMPInfo(randomChannels) {
      IMP_interbot_next_elect_do $chan
    }
  }
  set IMP_interbot_timer 1
  set delay [expr [rand 200] + 1700]
  IMP_putloglev 2 * "IMP: starting election timer"
  utimer $delay IMP_interbot_next_elect
}

proc IMP_interbot_next_elect_do { channel } {
  global IMP_interbot_nextbot_score IMP_interbot_nextbot_nick botnick IMPInfo

  set myScore [rand 100]
  if {$IMPInfo(away) == 1} {
    set myScore -2
  }
  set IMP_interbot_nextbot_score($channel) $myScore
  set IMP_interbot_nextbot_nick($channel) $botnick
  IMP_putloglev 3 * "IMP: assuming I'm the nextbot until I find another"
  catch {
    set bots [chanlist $channel]
    foreach bot $bots {
      #not me you idiot
      if [isbotnick $bot] { continue }
      IMP_putloglev 4 * "IMP: checking $bot for election in $channel"
      set handle [nick2hand $bot $channel]
      IMP_putloglev 4 * "IMP: checking $bot's handle; $handle"
      if {[matchattr $handle b&K $channel] && [islinked $handle]} {
        IMP_putloglev 2 * "IMP: sending elect_initial to $bot for $channel"
        putbot $handle "imp elect_initial $channel $myScore"
      }
      IMP_putloglev 4 * "IMP: checking $handle over" 
    }
  }
  IMP_putloglev 3 * "IMP: election over"
}

proc IMP_interbot_catch { bot cmd args } {
  global IMPInfo
  IMP_putloglev 3 * "IMP: incoming !$args!"
  set args [lindex $args 0]
  regexp {([^ ]+) (.+)} $args matches function params

  IMP_putloglev 2 * "IMP: got command $function ($params) from $bot"

  switch -exact $function {
    "say" {
      # imp say <channel> <text>
      IMPCatchSayChan $bot $params
    }

    "elect_initial" {
      IMP_interbot_next_incoming $bot $params
    }

    "elect_reply" {
      IMP_interbot_next_incoming_reply $bot $params
    }

    "fake_event" {
      IMP_interbot_fake_catch $bot $params
    }

    "HAY" {
      IMP_interbot_hay $bot $params
    }

    "SUP" {
      IMP_interbot_sup $bot $params
    }
  }

  return 0
}


proc IMP_interbot_next_incoming { bot params } {
  #another bot is forcing an election
  global IMP_interbot_nextbot_score IMP_interbot_nextbot_nick botnick IMPInfo

  IMP_putloglev 1 * "IMP: Incoming election from $bot"

  regexp "(\[#!\].+) (.+)" $params matches channel score
  if {$score > $IMP_interbot_nextbot_score($channel)} {
    IMP_putloglev 2 * "IMP: $bot now has highest score on $channel"
    set IMP_interbot_nextbot_score($channel) $score
    set IMP_interbot_nextbot_nick($channel) $bot
  }
  
  set myScore [rand 100]
  if {$IMPInfo(away) == 1} {
    set myScore -2
  }
  IMP_putloglev 2 * "IMP: My score is $myScore"

  if {$myScore > $IMP_interbot_nextbot_score($channel)} {
    IMP_putloglev 2 * "IMP: Actually, I have highest score on $channel, sending out reply"
    set IMP_interbot_nextbot_score($channel) $myScore
    set IMP_interbot_nextbot_nick($channel) $botnick

    set bots [chanlist $channel]
    foreach bot $bots {
      #not me you idiot
      if [isbotnick $bot] { continue }
      set handle [nick2hand $bot $channel]
      if [matchattr $handle b&K $channel] {
        putbot $handle "imp elect_reply $channel $myScore"
      }
    }
  }
}

proc IMP_interbot_next_incoming_reply { bot params } {
  #another bot is forcing an election
  global IMP_interbot_nextbot_score IMP_interbot_nextbot_nick 

  IMP_putloglev 1 * "IMP: Incoming election reply from $bot"

  regexp "(\[#!\].+) (.+)" $params matches channel score
  if {$score > $IMP_interbot_nextbot_score($channel)} {
    IMP_putloglev 2 * "IMP: $bot now has highest score on $channel"
    set IMP_interbot_nextbot_score($channel) $score
    set IMP_interbot_nextbot_nick($channel) $bot
  }
}

proc IMPSendSayChan { channel text thisBot} {
  #replace all ¬ with %
  set text [IMPInsertString $text "¬" "%"]
  IMP_putloglev 1 * "IMP: pushing command say ($channel $text) to $thisBot"
  if [islinked $thisBot] {
    putbot $thisBot "imp say $channel :$text"
    return $thisBot
  } else {
    putlog "IMP: ALERT! Trying to talk to bot $thisBot, but it isn't linked"
    return ""
  }
}

proc IMPCatchSayChan { bot params } {
  global IMPInfo
  global IMPQueueTimer

  IMP_putloglev 4 * "IMP: IMPCatchSayChan $bot $params"

  if [regexp {([#!][^ ]+) :(.+)} $params matches channel txt] {
  
    if {$IMPInfo(silence) == 1} {
      set IMPInfo(silence) 2
    }
    IMPDoAction $channel $bot $txt "" 0 1
    IMP_putloglev 1 * "IMP: done say command from $bot"
    if {$IMPInfo(silence) == 2} {
      set IMPInfo(silence) 1
    }
  } else {
    putlog "IMP ALERT! Error unwrapping command !say $params! from $bot"
  }
  return 0
}

# Check if we're due to talk next on the channel
# if yes, then force an election for that channel immediately afterwards
proc IMP_interbot_me_next { channel } {
  global IMP_interbot_nextbot_nick IMP_interbot_nextbot_score botnick

  set channel [string tolower $channel]

  #let's look to see if we know any other bots on the botnet
  if {[llength [IMP_interbot_otherbots $channel]] == 0} {
    return 1
  }

  set me 0 
  ## /|\  KIS hack
  catch {
    if {$IMP_interbot_nextbot_score($channel) < 0} {
      IMP_putloglev 4 * "IMP: nextbot_score is <0, I'm not answering"
      return 0
    }

    if {$IMP_interbot_nextbot_nick($channel) == $botnick} {
      IMP_putloglev 4 * "IMP: nextbot_nick is me"
      IMP_interbot_next_elect_do $channel
      set me 1 
      ## /|\ KIS hack
      return 1
    }
  }
  IMP_putloglev 4 * "IMP: nextbot_nick is not me" 
  #if it's noone, the winning bot will force an election anyway
  return $me 
  #return 0
  ## /|\ KIS hack, was 0, hacked to $me to force single botnet workings
}

# send a fake event
proc IMP_interbot_fake_event { botnick channel fromnick line } {
  if {[matchattr $botnick b&K $channel] && [islinked $botnick]} {
    putbot $botnick "imp fake_event $channel $fromnick $line"
    return 1
  }
}

# catch the fake event
proc IMP_interbot_fake_catch { bot params } {
  IMP_putloglev 1 * "Incoming fake event from $bot: $params"
  regexp {([^ ]+) ([^ ]+) (.+)} $params matches channel fromnick line
  #proc IMP_event_main {nick host handle channel text}
  putlog $line
  IMP_event_main $fromnick "fake@fake.com" $fromnick $channel $line
  return 1
}

#call an election when we start/rehash
foreach chan $IMPInfo(randomChannels) {
  set IMP_interbot_nextbot_score($chan) "-1"
  set IMP_interbot_nextbot_nick($chan) ""
}
IMP_interbot_next_elect

# IMP_interbot_link
#
# callback for a bot linking to the botnet
proc IMP_interbot_link { botname via } {
  #let's announce we're a imp bot
  putbot $botname "imp SUP [IMP_setting_get randomChannels]"
}

# IMP_interbot_hay
#
# Catches a HAY from another bot, replies with a SUP
proc IMP_interbot_hay { bot channels } {
  #we've met another imp bot, we need to tell it what channels we're on
  global IMP_interbot_otherbots
  set IMP_interbot_otherbots($bot) $channels
  putlog "IMP: Met IMP bot $bot on channels $channels"
  putbot $bot "imp SUP [IMP_setting_get randomChannels]"
  array unset IMP_interbot_otherbots dummy
}

# IMP_interbot_sup
#
# Catches a SUP (reply to my HAY)
proc IMP_interbot_sup { bot channels } {
  #we've met another imp bot
  global IMP_interbot_otherbots
  set IMP_interbot_otherbots($bot) $channels
  putlog "IMP: IMP bot $bot on channels $channels"
  array unset IMP_interbot_otherbots dummy
}

set IMP_interbot_otherbots(dummy) ""

# IMP_interbot_resync
#
# Broadcasts a HAY to see who's around
proc IMP_interbot_resync { } {
  #let's find out who's on the botnet
  global IMP_interbot_otherbots
  unset IMP_interbot_otherbots
  set IMP_interbot_otherbots(dummy) ""

  putloglev d * "IMP: Resyncing with botnet for IMP bots"
  putallbots "imp HAY [IMP_setting_get randomChannels]"
  utimer [expr [rand 900] + 300] IMP_interbot_resync
}

# IMP_interbot_otherbots
#
# Returns other bots we know on this channel
proc IMP_interbot_otherbots { channel } {
  global IMP_interbot_otherbots

  set otherbots [list]

  foreach bot [array names IMP_interbot_otherbots] {
    if {[lsearch $IMP_interbot_otherbots($bot) $channel] > -1} {
      lappend otherbots $bot
    }
  }
  return $otherbots
}

# set up our binds
bind bot - "imp" IMP_interbot_catch
bind link - * IMP_interbot_link

utimer [expr [rand 900] + 300] IMP_interbot_resync

IMP_putloglev d * "IMP: interbot module loaded"
