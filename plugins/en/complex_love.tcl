## IMP Module: love

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

IMP_plugin_add_complex "love" "(i )?(think )?(you are|you're )?(love|luv|wov|wuv|luvly|lovely)( you)? %botnick" 100 IMP_plugin_complex_love "en"

proc IMP_plugin_complex_love { nick host handle channel text } {
  if {![IMPLike $nick $host]} {
    frightened $nick $channel
    return 1
  }

  driftFriendship $nick 4

  if {$mood(happy) < 15 && $mood(lonely) < 5} {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{loveresponses}"
    IMPGetHappy
    IMPGetUnlonely
    set IMPCache(lastDoneFor) $nick
    return 1
  } else {
    IMPDoAction $channel "" "hehe, want to go out on a date someplace? :)"
    set mood(happy) [expr $mood(happy) - 10]
    set IMPCache(lastDoneFor) $nick
    return 1
  }
}
