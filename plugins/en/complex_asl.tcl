###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_complex "asl" {[[:<:]]a/?s/?l\??[[:>:]]} 100 IMP_plugin_complex_asl "en"
  
proc IMP_plugin_complex_asl { nick host handle channel text } {
  if {[IMPTalkingToMe $text] || [rand 2]} {
    set age [expr [rand 20] + 13]
    global IMPInfo
    IMPDoAction $channel $nick "%%: $age/$IMPInfo(gender)/%VAR{locations}"
    return 1
  }
  return 0
}
