## IMP plugin: fucks#

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

IMP_plugin_add_action_complex "fuck" "((s(e|3)x(o|0)r(s|z|5))|(fluffles)|fucks|paalt|shags|paalt|fondles|ravages|rapes|spanks|kisses|zoent) %botnicks" 100 IMP_plugin_complex_action_fucks "en"
proc IMP_plugin_complex_action_fucks { nick host handle channel text } {
  global botnicks
	if [regexp -nocase "((s(e|3)x(o|0)r(s|z|5))|(fluffles)|fucks|paalt|shags|paalt|fondles|ravages|rapes|spanks|kisses|zoent) $botnicks" $text] {    if {[regexp -nocase "(ass|arse|bottom|anal|rape(s)?|fist)" $text] && ![IMP_setting_get "kinky"]} {
      driftFriendship $nick -5
      frightened $nick $channel
      return 1
    }    if [IMPLike $nick $host] {
      driftFriendship $nick 4
      IMPDoAction $channel %% "%VAR{rarrs}"
      IMPGetHappy
      IMPGetHappy
      IMPGetHorny
      IMPGetUnLonely
    } else {      frightened $nick $channel
      driftFriendship $nick -1    }
		return 1
	}}
