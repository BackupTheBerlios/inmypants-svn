## IMP: replicate plugin

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

IMP_plugin_add_complex "replicate" "^%botnicks:?,? (please )?(replicate|create|send|make) (.+?\[^?\])$" 100 IMP_plugin_complex_replicate "en"
IMP_plugin_add_complex "replicate2" "^%botnicks:?,? (please )?(replicate|create|send|make) (.+) (for|to) (.+)" 100 IMP_plugin_complex_replicate2 "en"

proc IMP_plugin_complex_replicate { nick host handle channel text } {
  global botnicks

  regexp -nocase "^${botnicks}:?,? (please )?(replicate|create|send|make) (.+)" $text matches bot please action details

  #make it so
  if [regexp -nocase "^it so$" $details] { 
    IMPDoAction $channel $nick "/makes it so for %%"
    set IMPCache(lastDoneFor) $nick
    return 1
  }

  # make it something
  if [regexp -nocase "^it (.+)$" $details ming details2] {
    IMPDoAction $channel $nick "/makes it $details2 for %%"
    set IMPCache(lastDoneFor) $nick   
    return 1
  }

  # actually replicate
  set who [string trim [string range $details 0 [string first " " $details]]]
  set item [string range $details [expr [string first " " $details] + 1] [string length $details]]
  set whom ""
  if {$who == ""} {
    IMPDoAction $channel $nick "Idiot. Try pressing Alt-F4 for help, %%"
    return 0
  }
  if {$who == "me"} { set whom $nick }
  if {[regexp -nocase "(yourself|you)" $who]} { set whom [getPronoun] }
  if {$whom == ""} { set whom $who }
  if {[string tolower $action] == "make"} {
    if {($whom == [getPronoun]) && [regexp -nocase "(come|cum|ejaculate|squirt)" $item]} {
      cum $channel $nick
      return 0
    }
    if {[rand 4] == 0 || [regexp -nocase "into" $item]} {
      set whom "$whom is"
      if {$who == "me"} { set whom "you are" }
      if {[regexp -nocase "(yourself|you)" $who]} { set whom "I am" }
      if [regexp -nocase "into" $item] {
        set item [string range $item [expr [string first "into" $item] + 5] end]
      }
      set hisHers [getHisHers]
      global wands
      IMPDoAction $channel $hisHers [pickRandom $wands]
      IMPDoAction $channel $whom "*PING* ... $whom $item"
      if [rand 2] { IMPDoAction $channel $whom "I AM THE WIZARD%colen" }
      IMPGetHappy
      IMPGetUnLonely
      IMP_putloglev d * "IMP: Turned someone into $item :P"
      return 0
    }
  }
  IMP_putloglev d * "IMP: Replicated $item for $whom on $channel (requested by $nick)"
  IMPDoAction $channel $whom "/replicates $item and hands it to %%"
  IMPGetUnLonely
  set IMPCache(lastDoneFor) $nick
  return 1
}


proc IMP_plugin_complex_replicate2 { nick host handle channel text } {
  global botnicks botnick
  regexp -nocase "^${botnicks}:?,? (please )?(replicate|create|send|make) (.+?)( for| to) (.+)" $text matches bot please action details f who

  IMP_plugin_complex_replicate $nick $host $handle $channel "$botnick $action $who $details"
  return 1
}
