# IMP module to hold functions for handling questions, to keep them out of scripts/complex_questions.tcl


###############################################################################
# This is a IMP module thing
# it provides the answers to questions
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc IMP_question_where { nick channel host } {
    IMP_putloglev 2 * "$nick where question"
    #IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWheres}"
    if {[getFriendship $nick] < 35} {
	IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{upyourbums}"
    } else {
	IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWheres}"
    }
}

proc IMP_question_wellbeing { nick channel host } {
    ##boring code, replaced
    IMP_putloglev 2 * "$nick wellbeing question"
    #IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWellbeing}"
    #return 1

    global mood
    driftFriendship $nick 2

    set moodString ""
    #if {![IMPTalkingToMe $text]} { return 0 }
    if {[getFriendship $nick] > 75} {
	append moodString "Awww, thanks for asking "
	append moodString [IMPGetRealName $nick]
	append moodString ", "
    } else {
	if {[getFriendship $nick] < 35} {
	    append moodString "What do you care that "
	}
    }
    

    append moodString "I'm feeling "
    set moodIndex 0
    set done 0

    IMP_putloglev 4 * "lonely $mood(lonely)"    
    if {$mood(lonely) > 5} {
	append moodString "a bit lonely"
	incr moodIndex -2
	incr done 1
    }
    
    IMP_putloglev 4 * "horny $mood(horny)"
    if {$mood(horny) > 2} {
	if {$done > 0} {
	    append moodString ", "
	}
	append moodString "a little horny"
	incr moodIndex 2
	incr done 1
    }

    IMP_putloglev 4 * "happy $mood(happy)"        
    if {$mood(happy) > 3} {
	if {$done > 0} {
	    append moodString ", "
	}
	append moodString "happy"
	incr moodIndex 1
	incr done 1
    }


    if {$mood(happy) < 0} {
	if {$done > 0} {
	    append moodString ", "
	}
	append moodString "sad"
	incr moodIndex -3
	incr done 1
    }

    IMP_putloglev 4 * "stoned $mood(stoned)"    
    if {$mood(stoned) > 5} {
	if {$done > 0} {
	    append moodString ", "
	}
	append moodString "stoned off my tits"
	incr moodIndex 2
	incr done 1
    }
    
    if {$done < 1} {
	append moodString "pretty average :/"
# 	global feelings
# 	set moodString [IMP_abstract_get "feelings"]
    } else {
	if {$moodIndex >= 0} {
	    append moodString " :)"
	} else {
	    append moodString " :("
	}
    }
    
    IMPDoAction $channel [IMPGetRealName $nick $host] "%%: $moodString"
    return 1
}
