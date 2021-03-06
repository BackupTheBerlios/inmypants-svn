## IMP plugin: blblbl

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

#[ AfrObawt] The afronym for this round is AGNUE. You have 60 seconds.
IMP_plugin_add_complex "afro1" {^.he afr(o|0)nym for this round is[^A-Z]*[A-Z]+} 100 IMP_plugin_complex_afro_1 "en"
IMP_plugin_add_complex "afro1a" {^Acro for this round:[^A-Z]*[A-Z]+} 100 IMP_plugin_complex_afro_1a "en"

#1651.13 [ AfrObawt] Answers for Round 10
IMP_plugin_add_complex "afro2" {^Answers for round [0-9]+} 100 IMP_plugin_complex_afro_2 "en"
IMP_plugin_add_complex "afro2a" "^Current Acros:" 100 IMP_plugin_complex_afro_2 "en"

#1651.13 [ AfrObawt] 1. AShalimas grew numb under elJames
IMP_plugin_add_complex "afro3" {^[0-9]+\. .+} 100 IMP_plugin_complex_afro_3 "en"
IMP_plugin_add_complex "afro3a" {^.[0-9]+.} 100 IMP_plugin_complex_afro_3a "en"

# -=5 Seconds! =-
IMP_plugin_add_complex "afro4" "^5 seconds" 100 IMP_plugin_complex_afro_4 "en"
IMP_plugin_add_complex "afro4a" "^1st vote received!" 100 IMP_plugin_complex_afro_4 "en"

#admin
IMP_plugin_add_admin "afro" "^afro"              n       "IMP_plugin_admin_afro" "any"

#
# Invent an afronym and prepare to answer
proc IMP_plugin_complex_afro_1 { nick host handle channel text } {

  regexp -nocase {^The afr(o|0)nym for this round is[^A-Z]*([A-Z]+)} $text oh matches afronym
  IMP_putloglev d * "IMP: looks like i'm playing afronym, and it's $afronym"

  #invent a word
  set afroanswer ""
  set letters [split $afronym {}]
  foreach letter $letters {
    append afroanswer "%VAR{afro_$letter} "
    set afroanswer [IMPDoInterpolation $afroanswer "" "" ""]
  }

  IMP_putloglev 1 * "IMP: afroanswer is $afroanswer"

  utimer [expr [rand 30] + 8] IMP_plugin_complex_afro_answer

  #save the answer
  IMP_plugins_settings_set "afro" "answer" $channel $nick $afroanswer
  IMP_plugins_settings_set "afro" "channel" "" "" $channel
  IMP_plugins_settings_set "afro" "nick" "" "" $nick

  IMP_flood_undo $nick
  return 1
}

#
# catch alternate format
proc IMP_plugin_complex_afro_1a { nick host handle channel text } {
  regexp -nocase {^Acro for this round[^A-Z]*([A-Z]+)} $text matches afronym
  IMP_plugin_complex_afro_1 $nick $host $handle $channel "The afronym for this round is $afronym"
  IMP_flood_undo $nick
  return 1
}

#
# called by the timer to send the answer
proc IMP_plugin_complex_afro_answer { } {
  set channel [IMP_plugins_settings_get "afro" "channel" "" ""]
  set nick [IMP_plugins_settings_get "afro" "nick" "" ""]
  set myAnswer [IMP_plugins_settings_get "afro" "answer" $channel $nick]
  puthelp "PRIVMSG $nick :$myAnswer"
}

#
# switch to getting answers mode
proc IMP_plugin_complex_afro_2 { nick host handle channel text } {
  #this one spots the start of the answers

  IMP_flood_undo $nick

  IMP_plugins_settings_set "afro" "state" $channel $nick "listing"
  IMP_plugins_settings_set "afro" "answers" $channel $nick ""
}

#
# process an answer
proc IMP_plugin_complex_afro_3 { nick host handle channel text } {

  if {[IMP_plugins_settings_get "afro" "state" $channel $nick] != "listing"} {
    return 1
  }

  IMP_flood_undo $nick

  if [regexp {^([0-9]+)\. (.+)} $text matches answernum answer] {
    set myAnswer [IMP_plugins_settings_get "afro" "answer" $channel $nick]
    IMP_putloglev d * "Answer number $answernum is $answer (mine was $myAnswer)"
    if {![string match -nocase "$answer*" $myAnswer]} {
      set useAnswers [IMP_plugins_settings_get "afro" "answers" $channel $nick]
      append useAnswers "$answernum "
      IMP_plugins_settings_set "afro" "answers" $channel $nick $useAnswers
      #muwahahah steal some of the words used
      set words [split $answer " "]
      foreach word $words {
        if [regexp {([a-zA-Z]+)} $word matches newword] {
          set word $newword
        }
        if {[rand 3] && ([string length $word] > 2)} {          
          set word [string tolower $word]
          set firstletter [string toupper [string range $word 0 0]]
          set full_array_name_for_upvar "afro_$firstletter"
          upvar #0 $full_array_name_for_upvar teh_variable
          if {[lsearch $teh_variable $word] == -1} {
            lappend teh_variable $word
            IMP_putloglev d * "Learning word $word"
          }
        }
      }
      return 1
    } else {
      #it's my answer
      IMP_plugins_settings_set "afro" "myanswer" $channel $nick $answernum
      return 1
    }
  }
}

#
# catch alternate format
proc IMP_plugin_complex_afro_3a { nick host handle channel text } {
  #putlog "hi! $text"
  if [regexp -nocase {^.([0-9]+).[^A-Z]+(.+)} $text matches number acro] {
    IMP_plugin_complex_afro_3 $nick $host $handle $channel "$number. $acro"
    IMP_flood_clear $nick
    return 1
  }
}

#
# finally, send our vote in
proc IMP_plugin_complex_afro_4 { nick host handle channel text } {
  #send our vote

  if {[IMP_plugins_settings_get "afro" "state" $channel $nick] != "listing"} {
    return 1
  }

  IMP_plugins_settings_set "afro" "state" $channel $nick "idle"
  set answers [string trim [IMP_plugins_settings_get "afro" "answers" $channel $nick]]
  set answerList [split $answers " "]

  IMP_flood_clear $nick

  set ourVote [pickRandom $answerList]

  if {[rand 100] < 5} {
    #vote for us
    set myAnswer [IMP_plugins_settings_get "afro" "myanswer" $channel $nick]
    puthelp "PRIVMSG $nick :$myAnswer"
    IMP_putloglev d * "IMP: voting for myself :P"
    IMPDoAction $channel $nick "%VAR{oops}"
    return 0
  }

  puthelp "PRIVMSG $nick :$ourVote"
}


#word list (only init if empty
if {![info exists afro_A]} {
  set afro_A { "aardvark" "arse" "arrange" "american" }
  set afro_B { "balloon" "breasts" }
  set afro_C { "cheese" "cow" "cock" "chicken" "cup" "cupcake" }
  set afro_D { "dog" "dick" "doughnuts" "donkey" "dinner" "diner" }
  set afro_E { "elephant" "enormous" "eggs" }
  set afro_F { "fish" "fudge" "fuck" "fsck" "fucking" "fridge" }
  set afro_G { "goat" "green" "gang" "gong" "glass" "grapefruit" }
  set afro_H { "hippo" "horny" "honk" "hooters" }
  set afro_I { "igloo" "iceage" "is" "intelligent" "idiot" }
  set afro_J { "jam" "jump" "jumper" "jealous" "juice" }
  set afro_K { "kite" "kinky" }
  set afro_L { "llama" "lemon" "lift" "long" "lovely" }
  set afro_M { "moose" "moo" "ming" "mouth" }
  set afro_N { "noodle" "noise" "nice" "nerd" "new"}
  set afro_O { "orange" "opium" "optional" }
  set afro_P { "peas" "parents" "pornography" "pies" }
  set afro_Q { "quote" "quickly" "quick" }
  set afro_R { "rhubarb" "rubbing" "rhombus" }
  set afro_S { "sushi" "suck" "something" "seaside" "startrek" }
  set afro_T { "teapot" "toss" "timothy" }
  set afro_U { "undone" "upsidedown" "uber" }
  set afro_V { "violet" "veal" "very" }
  set afro_W { "wiggle" "wobble" "wank" }
  set afro_X { "xray" "xrated" "xylophone" }
  set afro_Y { "yellow" "yank" }
  set afro_Z { "zebra" "zeus" }
}
