# IMP - System function

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

# init our counters
IMP_counter_init "system" "randomstuff"

# this function cleans the CVS string to get the version out of it
proc IMPCleanCVSString { cvs } {
  if [regexp {\$[I][d].+?,(.+) Exp \$} $cvs matches core] {
    return $core
  }
  return $cvs
}
set cvsinfo [IMPCleanCVSString {$Id: system.tcl,v 1.21 2004/03/01 10:46:59 jamesoff Exp $}]
set randomsinfo ""

#Set up the binds

#General IRC events
bind join - *!*@* IMP_event_onjoin
bind mode - * IMP_event_mode
bind pubm - * IMP_event_main
bind sign - * IMP_event_onquit
bind nick - * IMP_event_nick
bind part - * IMP_event_onpart
bind ctcp - ACTION IMP_event_action

#IMP IRC events
bind pub - "!mood" pubm_moodhandler
bind pub - "!bminfo" IMPInfo
bind pub - "!bmstats" IMPStats
bind msg - imp msg_impcommand
bind pub - !impadmin IMPAdminHandler
bind pub - !imp IMPAdminHandler2

#DCC commands
bind dcc m mood moodhandler
bind dcc m imp* dcc_impcommand
bind dcc m impadmin* IMP_dcc_command
bind dcc m bmhelp IMP_dcc_help

foreach chan $IMPInfo(randomChannels) {
  set IMPLastEvent($chan) [clock seconds]
  set IMPInfo(adminSilence,$chan) 0
  #set to 1 when the bot says something, and 0 when someone else says something
  #used to make the bot a bit more intelligent (perhaps) at conversations
  set IMPCache($chan,last) 0
  #channel mood tracker
  set IMPCache($chan,mood) 0
}


proc IMPInfo {nick host handle channel text} {  
  global IMPInfo botnicks IMPSettings cvsinfo randomsinfo botnick
  global IMPVersion
  if {(![regexp -nocase $botnick $text]) && ($text != "all")} { return 0 }
  if {!([isvoice $nick] || [isop $nick]) || ($nick != "JamesOff")} { return 0 }
  set timezone [clock format [clock seconds] -format "%Z"]  
  putchan $channel "I am running IMP $IMPVersion under TCL [info patchlevel]."
  set status "botGender $IMPInfo(gender)/$IMPInfo(orientation) : balefire $IMPInfo(balefire) : pokemon $IMPInfo(pokemon) : timezone $timezone : randomStuff $IMPInfo(minRandomDelay), $IMPInfo(maxRandomDelay), $IMPInfo(maxIdleGap) : botnicks $botnicks : melMode $IMPSettings(melMode) : needI $IMPSettings(needI)"
  if {$IMPInfo(silence)} { set status "$status : silent (yes)" }
  putchan $channel $status
  return 0
}

proc IMPStats {nick host handle channel text} {  
  global IMPInfo botnicks IMPSettings cvsinfo randomsinfo botnick
  global IMPVersion
  if {(![regexp -nocase $botnick $text]) && ($text != "all")} { return 0 }
  if {!([isvoice $nick] || [isop $nick]) || ($nick != "JamesOff")} { return 0 }


  global IMP_abstract_contents IMP_abstract_timestamps IMP_abstract_max_age
  global IMP_abstract_ondisk

  set mem [llength [array names IMP_abstract_contents]]
  set disk [llength $IMP_abstract_ondisk]
  set faults [IMP_counter_get "abstracts" "faults"]
  set pageouts [IMP_counter_get "abstracts" "pageouts"]
  global IMPFacts
  set items [lsort [array names IMPFacts]]
  set itemcount 0
  set factcount 0
  foreach item $items {
    incr itemcount
    incr factcount [llength $IMPFacts($item)]
  }

  putchan $channel "abstracts: [expr $mem + $disk] total, $mem loaded, $disk on disk, $faults faults, $pageouts pageouts. [IMP_counter_get abstracts gc] garbage collections, [IMP_counter_get abstracts gets] fetches"
  putchan $channel "facts: $factcount facts about $itemcount items"
  putchan $channel "plugins fired: simple [IMP_counter_get events simpleplugins], complex [IMP_counter_get events complexplugins]"
  putchan $channel "output: lines sent to output: [IMP_counter_get output lines], lines sent to irc: [IMP_counter_get output irclines]"
  putchan $channel "system: randomness: [IMP_counter_get system randomstuff]"
  putchan $channel "flood: checks: [IMP_counter_get flood checks]"
}



proc doRandomStuff {} {
  global IMPInfo mood stonedRandomStuff IMPSettings
  global IMPLastEvent
  set timeNow [clock seconds]
  set saidChannels ""
  set silentChannels ""

  #do this first now
  set upperLimit [expr $IMPInfo(maxRandomDelay) - $IMPInfo(minRandomDelay)]
  set temp [expr [rand $upperLimit] + $IMPInfo(minRandomDelay)]
  timer $temp doRandomStuff
  IMP_putloglev d * "IMP: randomStuff next ($temp minutes)"


  #not away

  #find the most recent event
  set mostRecent 0
  set line "comparing idle times: "
  foreach channel $IMPInfo(randomChannels) {
    append line "$channel=$IMPLastEvent($channel) "
    if {$IMPLastEvent($channel) > $mostRecent} {
      set mostRecent $IMPLastEvent($channel)
    }
  }
  IMP_putloglev 1 * "IMP: most recent: $mostRecent .. timenow $timeNow .. gap [expr $IMPInfo(maxIdleGap) * 10]"
  
  set idleEnough 0

  if {($timeNow - $mostRecent) > ([expr $IMPInfo(maxIdleGap) * 10])} {
    set idleEnough 1
  }

  #override if we should never go away
  if {$IMPSettings(useAway) == 0} {
    set idleEnough 0
  }

  if {$idleEnough} {
    if {$IMPInfo(away) == 1} {
      #away, don't do anything
      return 0
    }

    #channel is quite idle
    if {[rand 4] == 0} {
      putlog "IMP: All channels are idle, going away"
      IMPSetRandomAway
      return 0
    }
  }

  #not idle
  
  #set back if away
  if {$IMPInfo(away) == 1} {
    IMPSetRandomBack
  }

  #we didn't set ourselves away, let's do something random
  IMP_counter_incr "system" "randomstuff"
  foreach channel $IMPInfo(randomChannels) {
    if {($timeNow - $IMPLastEvent($channel)) < ($IMPInfo(maxIdleGap) * 60)} {
      set saidChannels "$saidChannels $channel"
      IMPSaySomethingRandom $channel
    } else {
      set silentChannels "$silentChannels $channel"
    }
  }
  IMP_putloglev d * "IMP: randomStuff said ($saidChannels) silent ($silentChannels)"
}

proc IMPSaySomethingRandom {channel} {
  global randomStuff stonedRandomStuff randomStuffMale randomStuffFemale mood IMPInfo
  
  if [rand 2] {
    IMPDoAction $channel "" "%VAR{randomStuff}"
  }

  return 0
}

proc IMPSetRandomAway {} {
  #set myself away with a random message
  global randomAways IMPInfo IMPSettings

  set awayReason [IMP_abstract_get "randomAways"]
  foreach channel $IMPInfo(randomChannels) {
    if {[lsearch $IMPSettings(noAwayFor) $channel] == -1} {
      IMPDoAction $channel $awayReason "/is away: %%"
    }
  }
  putserv "AWAY :$awayReason"
  set IMPInfo(away) 1
  set IMPInfo(silence) 1
  IMP_putloglev d * "IMP: Set myself away: $awayReason"
  IMP_putloglev d * "IMP: Going silent"
}

proc IMPSetRandomBack {} {
  #set myself back
  global IMPInfo IMPSettings

  set IMPInfo(away) 0
  set IMPInfo(silence) 0
  foreach channel $IMPInfo(randomChannels) {
    if {[lsearch $IMPSettings(noAwayFor) $channel] == -1} {
      IMPDoAction $channel "" "/is back"
    }
  }
  putserv "AWAY"

  #elect cos we're available now
  IMP_interbot_next_elect

  return 0
}

## IMPTalkingToMe ########################################################
proc IMPTalkingToMe { text } {
  global botnicks
  IMP_putloglev 2 * "checking $text to see if they're talking to me"
  if [regexp -nocase "(^${botnicks}:?|${botnicks}\\?$)" $text] {
    IMP_putloglev 2 * "`- yes"
    return 1
  }
  IMP_putloglev 2 * "`- no"
  return 0
}

## IMPSilence ############################################################
# Makes the bot shut up
##############################################################################
proc IMPSilence {nick host channel} {
  global IMPInfo silenceAways IMPSettings
  if {$IMPInfo(silence) == 1} {
    #I already am :P
    putserv "NOTICE $nick :I already am silent :P"
    return 0
  }
  timer $IMPSettings(silenceTime) IMPUnSilence
  putlog "IMP: Was told to be silent for $IMPSettings(silenceTime) minutes by $nick in $channel"
  set awayStuff [pickRandom $silenceAways]
  IMPDoAction $channel $nick $awayStuff
  putserv "AWAY :afk ($nick $channel)"
  set IMPInfo(silence) 1
  set IMPInfo(away) 1
}

## IMPUnSilence ##########################################################
# Undoes the shut up command
##############################################################################
proc IMPUnSilence {} {
  # Timer for silence expires
  putserv "AWAY"
  putlog "IMP: No longer silent."
  global IMPInfo
  set IMPInfo(silence) 0
  set IMPInfo(away) 0
}

proc IMPLike {nick { host "" }} {
  global IMPInfo mood IMPSettings
  if {$host == ""} {
    set host [getchanhost $nick]
  }

  set host "$nick!$host"

  if {$IMPSettings(melMode) == 1} {
    return 1
  }

  set handle [finduser $host]
  if {$handle == "*"} {
    # couldn't find a match
    #if i'm stoned enough, i'll sleep with anyone
    if {$mood(stoned) > 20} {
      return 1
    }

    #if i'm horny enough, i'll sleep with anyone
    if {$mood(horny) > 10} {
      return 1
    }
    #else they can get lost
    return 0
  }

  #don't like people who aren't my friends
  if {![IMPIsFriend $nick]} { return 0 }

  # we're friends, now get their gender
  set gender [getuser $handle XTRA gender]
  if {$gender == ""} {
    # they don't have a gender. let's assume we'd have sex with them too
    return 1
  }
  if {$gender == $IMPInfo(gender)} {
    #they're my gender
    if {($IMPInfo(orientation) == "bi") || ($IMPInfo(orientation) == "gay") || ($IMPInfo(orientation) == "lesbian")} {
      return 1
    }
    return 0
  }
  #they're not my gender. what now?
  if {($IMPInfo(orientation) == "bi") || ($IMPInfo(orientation) == "straight")} {
    return 1
  }
  # that only leaves lesbian and gay who won't sleep with the opposite gender
  return 0
}

proc IMPGetGender { nick host } {
  set host "$nick!$host"
  set handle [finduser $host]
  if {$handle == "*"} {
    return "unknown"
  }
  # found a user, now get their gender
  return [getuser $handle XTRA gender]
}

proc loldec {} {
  return 0
}

proc getHour {} {
  return [clock format [clock seconds] -format "%H"]
}

proc IMP_dcc_command { handle idx arg } {
  global IMPInfo
  IMP_putloglev 2 * "IMP: admin command $arg from $handle"
  set info [IMP_plugin_find_admin $arg $IMPInfo(language)]
  if {$info == ""} {
    putidx $idx "What? You need .bmhelp!"
    return 1
  }

  set blah [split $info "¦"]
  set flags [lindex $blah 0]
  set callback [lindex $blah 1]

  if {![matchattr $handle $flags]} {
    putidx $idx "What? You need more flags :)"
    return 1
  }

  IMP_putloglev d * "IMP: admin callback matched, calling $callback"

  #strip the first command
  regexp {[^ ]+( .+)?} $arg {\1} arg

  #run the callback :)
  set arg [join $arg]
  set arg [string trim $arg]
  catch {
    if {$arg == ""} {
      $callback $handle $idx
    } else {
      $callback $handle $idx $arg
    }
  } err
  if {($err != "") && ($err != 0)} {
    putlog "IMP: ALERT! Callback failed for .impadmin: $callback ($handle $idx $arg)"
    putidx $idx "Sorry :( Running your callback failed ($err)\r"
  }
}

proc IMP_dcc_help { handle idx arg } {
  putidx $idx "Commands available: (Some may not be accessible by you)\r"

  set cmds ""
  
  global IMP_plugins_admin
  set s [array startsearch IMP_plugins_admin]
  while {[set key [array nextelement IMP_plugins_admin $s]] != ""} {
    if {$key == "dummy"} { continue }
    append cmds "$key     "
  }

  putidx $idx "$cmds\r"
  array donesearch IMP_plugins_admin $s
}

proc dcc_impcommand { handle idx arg } {
  if [regexp -nocase "redo botnicks" $arg] {
    putidx $idx "!IMP! now redoing botnicks..."
    global botnicks botnick IMPSettings
    set botnicks "($botnick|$IMPSettings(botnicks)) ?"
    putidx $idx "!IMP! botnicks are now: $botnicks"
    return 1
  }

  if [regexp -nocase "reload" $arg] {
    putidx $idx "!IMP! reloading randoms file"
    source scripts/IMPSettings.tcl
    return 1
  }

  if [regexp -nocase "unsilence" $arg] {
    global IMPInfo
    putserv "AWAY"
    putidx $idx "No longer silent."
    set IMPInfo(silence) 0
    set IMPInfo(away) 0    
    return 1
  }

  if [regexp -nocase "unbind votes" $arg] {
      putidx $idx "Unbinding vote commands...\n"
      unbind pub - "!vote" IMPVoteHandler
      putidx $idx "ok\n"
      return 1
  }
 
  return 1
}


# new admin plugins ("management")
proc IMPAdminHandler2 {nick host handle channel text} {
  global botnicks IMPInfo botnick IMPSettings

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$IMPSettings(botnicks)) ?"
  }

  if {![regexp -nocase "^($botnicks)|all" $text]} {
    #not me
    return 0
  }

  regexp -nocase "^(($botnicks)|all) (.+)" $text matches blah blah2 blah3 cmd

  IMP_plugins_settings_set "admin" "type" "" "" "irc"
  IMP_plugins_settings_set "admin" "target" "" "" $channel

  #putlog "IMP command from $nick in $channel: $cmd"
  set nfo [IMP_plugin_find_management $cmd]

  if {$nfo == ""} {
    IMP_putadmin "what"
    return 1
  }

  set blah [split $nfo "¦"]
  set flags [lindex $blah 0]
  set callback [lindex $blah 1]

  if {![matchattr $handle $flags]} {
    IMP_putadmin "What? You need more flags :)"
    return 1
  }

  IMP_putloglev d * "IMP: management callback matched, calling $callback"

  #strip the first command
  regexp {[^ ]+( .+)?} $cmd {\1} arg

  #run the callback :)
  set arg [join $arg]
  set arg [string trim $arg]

  catch {
    if {$arg == ""} {
      $callback $handle
    } else {
      $callback $handle $arg
    }
  } err
  if {($err != "") && ($err != 0)} {
    putlog "IMP: ALERT! Callback failed for !imp: $callback: $err"
  }  
}

proc IMP_putadmin { text } {

  set output [IMP_plugins_settings_get "admin" "type" "" ""]
  if {$output == ""} {
    return 0
  }

  putlog $output

  if {$output == "dcc"} {
    set idx [IMP_plugins_settings_get "admin" "idx" "" ""]
    putidx $idx $text
    return 0
  }

  if {$output == "irc"} {
    set target [IMP_plugins_settings_get "admin" "target" "" ""]
    puthelp "PRIVMSG $target :$text"
    return 0
  }
  return 0
}

proc IMPAdminHandler {nick host handle channel text} {
  global IMPAdminFlag botnicks IMPInfo botnick IMPSettings

  if {![matchattr $handle $IMPAdminFlag $channel]} {
    return 0
  }

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$IMPSettings(botnicks)) ?"
  }

  if [regexp -nocase "$botnicks (shut up|silence|quiet)" $text] {
    set IMPInfo(adminSilence,$channel) 1
    puthelp "NOTICE $nick :OK, silent in $channel until told otherwise"
    return 1
  }

  if [regexp -nocase "$botnicks (end|cancel|stop) (shut up|silence|quiet)" $text] {
    set IMPInfo(adminSilence,$channel) 0
    puthelp "NOTICE $nick :No longer silent in $channel"
    return 1
  }

  if [regexp -nocase "$botnicks washnick (.+)" $text matches bn nick2] {
    IMPDoAction $channel $nick "%%: %2" [IMPWashNick $nick2]
    return 1
  }

  if [regexp -nocase "$botnicks global (shut up|silence|quiet)" $text] {
    set IMPInfo(silence) 1
    set IMPInfo(away) 1
    puthelp "NOTICE $nick :Now globally silent"
    putserv "AWAY :Global silence requested by $nick"
    return 1
  }

  if [regexp -nocase "$botnicks (end|cancel|stop) global (shut up|silence|quiet)" $text] {
    set IMPInfo(silence) 0
    set IMPInfo(away) 0
    puthelp "NOTICE $nick :No longer globally silent"
    putserv "AWAY";
    return 1
  }

  if [regexp -nocase "$botnicks leet (on|off)" $text blah pop toggle] {

    if {$toggle == "off"} {
      putlog "IMP: Leet mode off by $nick"     
      set IMPInfo(leet) 0
      IMPDoAction $channel $nick "/stops talking like a retard."
      return 0
    }

    if {$toggle == "on"} {
      putlog "IMP: Leet mode on by $nick"
      set IMPInfo(leet) 1
      IMPDoAction $channel $nick "Leet mode on ... fear my skills!"
    }
    return 1
  }

  if [regexp -nocase "$botnicks dutch (on|off)" $text blah pop toggle] {

    if {$toggle == "off"} {
      putlog "IMP: Dutch mode off by $nick"     
      set IMPInfo(dutch) 0
      IMPDoAction $channel $nick "/stops talking like a European."
      return 0
    }

    if {$toggle == "on"} {
      putlog "IMP: Dutch mode on by $nick"      
      IMPDoAction $channel $nick "/snapt wel nederlands"
      set IMPInfo(dutch) 1
    }
    return 1
  }


  if [regexp -nocase "$botnicks leetchance (.+)" $text blah pop value] {
    set IMPInfo(leetChance) $value
    puthelp "NOTICE $nick :Ok"
    return 1
  }

  if [regexp -nocase "$botnicks reload" $text blah pop value] {
    puthelp "NOTICE $nick :Reloading random stuff lists"
    source scripts/IMPRandoms.tcl
    putlog "IMP: Reloaded IMP randoms ($nick)"
    return 1
  }

  if [regexp -nocase "$botnicks parse (.+)" $text matches bot txt] {
    IMPDoAction $channel $nick $txt
    putlog "IMP: Parsed text for $nick"
    return 1
  }

  if [regexp -nocase "$botnicks su (.+?) (.+)" $text matches bot nick2 txt] {
    IMP_event_main $nick2 [getchanhost $nick2 $channel] [nick2hand $nick2] $channel $txt
    putlog "IMP: su to $nick2 by $nick on $channel: $txt"
    return 1
  }
}

proc msg_impcommand { nick host handle cmd } {
  IMP_plugins_settings_set "admin" "type" "" "" "irc"
  IMP_plugins_settings_set "admin" "target" "" "" $nick

  #putlog "IMP command from $nick in $channel: $cmd"
  regsub "(imp )" $cmd "" cmd
  set nfo [IMP_plugin_find_management $cmd]

  if {$nfo == ""} {
    IMP_putadmin "what"
    return 1
  }

  set blah [split $nfo "¦"]
  set flags [lindex $blah 0]
  set callback [lindex $blah 1]

  if {![matchattr $handle $flags]} {
    IMP_putadmin "What? You need more flags :)"
    return 1
  }

  IMP_putloglev d * "IMP: management callback matched, calling $callback"

  #strip the first command
  regexp {[^ ]+( .+)?} $cmd {\1} arg

  #run the callback :)
  set arg [join $arg]
  set arg [string trim $arg]

  catch {
    if {$arg == ""} {
      $callback $handle
    } else {
      $callback $handle $arg
    }
  } err
  if {($err != "") && ($err != 0)} {
    putlog "IMP: ALERT! Callback failed for !imp: $callback"
  }  
}

# Time stuff
 set pronounce {vigintillion novemdecillion octodecillion \
        septendecillion sexdecillion quindecillion quattuordecillion \
        tredecillion duodecillion undecillion decillion nonillion \
        octillion septillion sextillion quintillion quadrillion \
        trillion billion million thousand ""}

 proc get_num num {
    foreach {a b} {0 {} 1 one 2 two 3 three 4 four 5 five 6 six 7 seven \
            8 eight 9 nine 10 ten 11 eleven 12 twelve 13 thirteen 14 \
            fourteen 15 fifteen 16 sixteen 17 seventeen 18 eighteen 19 \
            nineteen 20 twenty 30 thirty 40 forty 50 fifty 60 sixty 70 \
            seventy 80 eighty 90 ninety} {if {$num == $a} {return $b}}
    return $num
 }


 proc revorder list {
    for {set x 0;set y [expr {[llength $list] - 1}]} {$x < $y} \
	    {incr x;incr y -1} {
	set t [lindex $list $x]
	set list [lreplace $list $x $x [lindex $list $y]]
	set list [lreplace $list $y $y $t]
    }
    return $list
 }

 proc pron_form num {
    global pronounce
    set x [join [split $num ,] {}]
    set x [revorder [split $x {}]]
    set pron ""
    set ct [expr {[llength $pronounce] - 1}]
    foreach {a b c} $x {
	set p [pron_num $c$b$a]
	if {$p != ""} {
	    lappend pron "$p [lindex $pronounce $ct]"
	}
	incr ct -1
    }
    return [join [revorder $pron] ", "]
 }

proc IMP_get_number { num } {
  return [expr [rand $num] + 1]
  set hundred ""
  set ten ""
  set len [string length $num]
  if {$len == 3} {
    set hundred "[get_num [string index $num 0]] hundred"
    set num [string range $num 1 end]
  }
  if {$num > 20 && $num != $num/10} {
    set tens [get_num [string index $num 0]0]
    set ones [get_num [string index $num 1]]
    set ten [join [concat $tens $ones] -]
  } else {
    set ten [get_num $num]
  }
  if {[string length $hundred] && [string length $ten]} {
    return [concat $hundred and $ten]
  } else {
    # One of these is empty, but don't bother to work out which!
    return [concat $hundred $ten]
  }
}

proc IMP_startTimers { } { 
  global mooddrifttimer
	if  {![info exists mooddrifttimer]} {
		timer 10 driftmood
    #utimer 5 loldec
    timer [expr [rand 30] + 3] doRandomStuff
		set mooddrifttimer 1
    set delay [expr [rand 200] + 1700]
    utimer $delay IMP_interbot_next_elect
	}
}

proc IMP_cleanNick { nick { handle "" } } {
  #attempt to clean []s etc out of nicks

  if {![regexp {[\\\[\]\{\}]} $nick]} {
    return $nick
  }

  if {($handle == "") || ($handle == "*")} {
    set handle [nick2hand $nick]
  }

  if {($handle != "") && ($handle != "*")} {
    set nick $handle
  }

  #have we STILL got illegal chars?
  if {[regexp {[\\\[\]\{\}]} $nick]} {
    return [string map { \[ "_" \] "_" \{ "_" \} "_" } $nick]
  }  
  return $nick
}

# IMP_uncolen
#
# clean out $£(($ off the end
proc IMP_uncolen { line } {
  regsub -all {([!\"\£\$\%\^\&\*\(\)\#\@]{3,})} $line "" line
  return $line
}

# IMP_setting_get
#
# get a setting out of the two variables that commonly hold them
proc IMP_setting_get { setting } {
  global IMPSettings
  global IMPInfo
  set val ""
  catch {
    set val $IMPSettings($setting)
  }
  if {$val != ""} {
	  return $val
  }
  
  IMP_putloglev 3 * "setting '$setting' doesn't exist in IMPSettings, trying IMPInfo..."
  catch {
    set val $IMPInfo($setting)
  }
  if {$val != ""} {
	  return $val
  
  }
  
  IMP_putloglev 3 * "nope, not there either, returning nothing"
  return ""
}

IMP_putloglev d * "IMP: system module loaded"
