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

proc IMP_plugin_complex_shock { nick host handle channel text } {
  global IMPCache
  #if we spoke last, it's probable this is a reaction to us
  #being surprised at yourself is lame
  if {$IMPCache($channel,last)} {
    return 0
  }

  IMPDoAction $channel $nick "%VAR{shocked}"
  return 1
}

IMP_plugin_add_complex "shocked" "^((((=|:|;)-?(o|0))|(!+))|blimey|crumbs|i say)$" 40 IMP_plugin_complex_shock "en"
