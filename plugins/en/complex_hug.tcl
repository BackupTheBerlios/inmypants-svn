## IMP plugin: hug

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

IMP_plugin_add_complex "hug" "%botnicks hug " 100 IMP_plugin_complex_hug "en"

proc IMP_plugin_complex_hug { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^$botnicks hug (.+)" $text matches bn item] {
    IMP_plugin_complex_hug_do $channel $item $host
    return 1
  }
}

proc IMP_plugin_complex_hug_do { channel nick host } {
  if [IMPIsFriend $nick] {
    set nick [IMPTransformNick $nick $nick $host]
    IMPGetUnLonely
    IMPGetHappy
    IMPDoAction $channel $nick "%VAR{hugs}"
  } else {
    IMPDoAction $channel $nick "%VAR{blehs}"
  }
}
