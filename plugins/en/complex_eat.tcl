## IMP plugin: eat

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

IMP_plugin_add_complex "eat" "^%botnicks,?:? (please)?eat " 100 IMP_plugin_complex_eat "en"

proc IMP_plugin_complex_eat { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^${botnicks},?:? (please)?eat (.+)" $text ming ming1 ming2 details] {
    IMPDoAction $channel $nick "/eats $details"
    if [regexp -nocase $botnicks $details] {
      IMPDoAction $channel "" "mmmmm... recursive"
    }
    IMPGetUnLonely
    return 1
  }
}
