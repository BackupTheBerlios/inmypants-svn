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

IMP_plugin_add_complex "blbl" "bl{2,}" 50 IMP_plugin_complex_blbl "en"

proc IMP_plugin_complex_blbl { nick host handle channel text } {
    IMPGetHorny
    IMPGetHappy
    if {![IMP_interbot_me_next $channel]} { return 0 }
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{rarrs}"
    return 1
  }
}
