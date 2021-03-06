## IMP plugin: gollum

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

IMP_plugin_add_complex "gollum" "precious" 50 IMP_plugin_complex_gollum "en"

proc IMP_plugin_complex_gollum { nick host handle channel text } {
    IMP_putloglev 2 * "IMP: run complex_gollum,"
    if {![IMP_interbot_me_next $channel]} { 
	IMP_putloglev 4 * "IMP: would have run gollum, but not my turn"
	return 0 
    }
    IMP_putloglev 4 * "IMP: my turn when running complex_gollum"
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{gollums}"
    return 0 
    #this allows us to still respond to questions, right?
  }
}

IMP_abstract_register "gollums"
IMP_abstract_batchadd "gollums" [list "Foolishness!" "Stupid fat hobbit!" "We hates the fat hobbit! Him and his pots and pans and ropes." "Thieves. Thieves all!" "Stupid hobbit. Talking to himself like that. Not answering himself." "Yes. Sleep sweet sleep with our precious!" "Filthy little thief playing with our precious!" "If only fat hobbit would go away for a moment, we could go to master and take the precious away from him." "No! Must not take away our precious!" "We miss the song of the precious. We miss it. We wants it back!" "Everyone wants my precious. It's not fair! It's ours!" "Shiny, shiny." ]
