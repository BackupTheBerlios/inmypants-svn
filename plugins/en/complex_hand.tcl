## IMP plugin: hand

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

IMP_plugin_add_complex "hand" "^%botnicks:?,? (please )?(pass|hand|give) (.+)" 100 IMP_plugin_complex_hand "en"

proc IMP_plugin_complex_hand { nick host handle channel text } {
  global botnicks
  regexp -nocase "^${botnicks}:?,? (please )?(pass|hand|give) (.+)" $text matches botn please verb details
  set who [string trim [string range $details 0 [string first " " $details]]]
  set item [string range $details [expr [string first " " $details] + 1] [string length $details]]

  if {[regexp -nocase "blow job|fuck|shag" $item]} {
    #TODO: add IMPLike here
    IMPDoAction $channel "" "No."
    return 1
  }

  if [regexp -nocase {[[:<:]](hug|cuddle|knuffel)[[:>:]]} $item] {
    #we're being asked to hug someone
    if [IMP_plugin_check_depend "complex:hug"] {
      IMP_plugin_complex_hug_do $channel $who $host
    } else {
      IMPDoAction $channel $nick "%%: I'm sorry, I don't know how to hug %VAR{unsmiles}"
    }
    return 1
  }

  set whom [IMPGetRealName $who]

  #your -> his/her
  if [string match -nocase "your *" $item] {
    set item "[getHisHers] [string range $item 5 end]"
  }

  if [string match -nocase "something" $item] {
    set item "%VAR{sillyThings}"
  }
  IMP_putloglev d * "IMP: Handed $whom $item on $channel (from $nick)"
  IMPDoAction $channel $nick "/gives $whom $item"
  IMPGetUnLonely
  return 1
}
