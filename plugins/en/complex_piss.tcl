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

IMP_plugin_add_complex "piss" "^%botnicks:?,? (wee|piss|pee|urinate|empty your bladder) on " 100 IMP_plugin_complex_piss "en"
  
proc IMP_plugin_complex_piss { nick host handle channel text } {
	global botnicks
	if [regexp -nocase "${botnicks}:?,? (please)?(piss|pee|urinate|empty your bladder) on (.+?)" $text ming ming1 ming2 ming3 who] {
		IMPDoAction $channel $who [pickRandom %VAR{pissOns}]
	}
}
