##IMP plugin: supermarkets

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

IMP_plugin_add_complex "supermarkets" {[[:<:]](sainsbury\'s|sainsburys|safeway|aldi|asda|walmart|wal-mart|wal mart|somerfield|lidl|co-op|budgens|cws|kiwk-save|kwiksave|kwik save|budgens|iceland|circle k|k-mart|7-11|costcutter|costco|marks and spencers|m&s|marks and sparks|mace-line|waitrose)[[:>:]]} 40 IMP_plugin_complex_supermarket "en"

proc IMP_plugin_complex_supermarket { nick host handle channel text } {
  if {![IMP_interbot_me_next $channel]} { return 1 }
  if [regexp -nocase {[[:<:]](sainsbury\'s|sainsburys|safeway|aldi|asda|walmart|wal-mart|wal mart|somerfield|lidl|co-op|budgens|cws|kiwk-save|kwiksave|kwik save|budgens|iceland|circle k|k-mart|7-11|costcutter|costco|marks and spencers|m&s|marks and sparks|mace-line|waitrose)[[:>:]]} $text matches where ] {
    IMPDoAction $channel $where "%VAR{insultsupermarket}"
    driftFriendship $nick -1
  }
}
