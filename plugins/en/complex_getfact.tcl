###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) Kevin Smith 2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the 
# distribution; further information can be found in the headers of the scripts 
# in the modules directory. 
###############################################################################

#
# Makes the bot return a random fact
#
# Usage:
#	!fact  
#	botname what do you know 
#	botname tell me something new

proc IMP_plugin_complex_get_fact { nick host handle channel text } {
	set intro "%VAR{get_fact_intros}"
	global IMPFacts

	set items [array names IMPFacts]
	#this gets a random item to give a fact about
	set i [lindex $items [rand [llength $items]]]
	if {[regexp "what,(.+)" $i matches item]} {
		#set item 
	}
	#set property $IMPFacts(what,$item)
	set property [lindex $IMPFacts(what,$item) [rand [llength $IMPFacts(what,$item)]]]
	#get a random name from the realnames of $nick
	set nick [IMPGetRealName $nick]
	#give the people what they want!
	IMPDoAction $channel $nick "$intro $item was $property"
	return 1
}

IMP_plugin_add_complex "getfact1" "^!fact" 100 IMP_plugin_complex_get_fact "en"
IMP_plugin_add_complex "getfact2" "^%botnicks what do you know" 100 IMP_plugin_complex_get_fact "en" 
IMP_plugin_add_complex "getfact3" "^%botnicks tell me something new" 100 IMP_plugin_complex_get_fact "en"

set get_fact_intros {
  "I think I heard that"
  "last time I knew, "
  "it could be that"
  "ok, I'll tell you that"
  "well, don't tell anyone, but......."
}

#new abstract system
IMP_abstract_register "get_fact_intros"
IMP_abstract_batchadd "get_fact_intros" $get_fact_intros
unset get_fact_intros

