# simsea's "Invader Zim" plugin

###############################################################################
# This is a IMP plugin
# Copyright (C) Andrew Payne 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# IMP_plugin_complex_invader_duty
# specific Gir moment... whenever anyone says duty (or duty sounding word)
# IMP responds with some suitably random dootie phrase
proc IMP_plugin_complex_invader_duty { nick host handle channel text } {
	global randomDootie
  if {![IMP_interbot_me_next $channel]} { return 0 }
	IMPDoAction $channel "" "%VAR{randomDootie}"

	# log this action 
	IMP_putloglev d * "IMP: (invader:duty) hehehe $nick said dootie"
}
# end IMP_plugin_complex_invader_duty

# IMP_plugin_complex_invader_zim
# general Invader Zim moments. will respond with random Invader Zim statement
proc IMP_plugin_complex_invader_zim { nick host handle channel text } {
	global randomZimness botnick
  if {![IMP_interbot_me_next $channel]} { return 0 }
	IMPDoAction $channel "" "%VAR{randomZimness}"
	
	#log this action
	IMP_putloglev d * "IMP: (invader:zim) $nick invoked the wrath of invader $botnick"
}
# end IMP_plugin_complex_invader_zim

# IMP_plugin_complex_invader_gir
# general Gir moments, will respond with suitably insane Gir comment
proc IMP_plugin_complex_invader_gir { nick host handle channel text } {
	global randomGirness botnick
  if {![IMP_interbot_me_next $channel]} { return 0 }
	IMPDoAction $channel "" "%VAR{randomGirness}"
	
	#log this action
	IMP_putloglev d * "IMP: (invader:gir) i like dootie"
}
# end IMP_plugin_complex_invader_gir

# IMP_plugin_complex_invader_nick
proc IMP_plugin_complex_invader_nick { nick host handle channel newnick } {
  if {![IMP_interbot_me_next $channel]} { return 1 }
  
  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:returned" "lastnick" $channel ""]} {
    return 0
  }

  #check we haven't already done something for this nick
  if {$nick == [IMP_plugins_settings_get "complex:away" "lastnick" $channel ""]} {
    return 0
  }

  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:away" "lastnick" $channel "" $newnick


  #save as newnick because if they do a /me next it'll be their new nick
  IMP_plugins_settings_set "complex:returned" "lastnick" $channel "" $newnick
  
  IMPDoAction $channel $nick "%VAR{randomZimNameChange}"
  return 0
}
# end IMP_plugin_complex_invader_nick

# random zimlike phrases
IMP_abstract_register "randomZimness"

# random girlike phrases
IMP_abstract_register "randomGirness"

# random "duty" responses... inevitable Gir
IMP_abstract_register "randomDootie"

# random zim/gir name change responses
IMP_abstract_register "randomZimNameChange"

# callbacks

# "duty" plugin responds to "duty" and variations of "dootie"
IMP_plugin_add_complex "invader(duty)" "duty|doo+(t|d)(ie|y)" 20 "IMP_plugin_complex_invader_duty" "en"

# "zim" plugin responds to "invade or invasion" "zim" "mwahahaha or hahaha" "victory for" "how dare" "you dare"
IMP_plugin_add_complex "invader(zim)" "zim|inva(de|sion)|((mwa)?ha(ha)+)|(victory for)|((you|how) dare)" 20 "IMP_plugin_complex_invader_zim" "en"

# "gir" plugin responds to "gir" "whooo or wooo" "chicken" "doom" "piggy", now with new improved "finally!
IMP_plugin_add_complex "invader(gir)" "w(h)?oo+|chicken|gir(!+| )|doo+m|piggy|finally!" 20 "IMP_plugin_complex_invader_gir" "en"

# nick change response
IMP_plugin_add_irc_event "invader(nick)" "nick" ".*" 5 "IMP_plugin_complex_invader_nick" "en"

