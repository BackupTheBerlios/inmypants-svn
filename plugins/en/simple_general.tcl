# IMP simple plugins
# Modify this to fit your needs :)
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

#                         name  regexp            %  responses
IMP_plugin_add_simple "url-img" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}.+\.(jpg|jpeg|gif|png)} 25 "%VAR{rarrs}" "en"
IMP_plugin_add_simple "url-gen" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}} 15 "%VAR{bookmarks}" "en"
IMP_plugin_add_simple "ali g" "^((aiii+)|wikkid|innit|respect|you got me mobile|you iz)" 40 "%VAR{aiis}" "en"
IMP_plugin_add_simple "wassup" "^wa+((ss+)|(zz+))u+p+(!*)?$" 40 "wa%REPEAT{4:12:a}up!" "en"
IMP_plugin_add_simple "oops" "^(oops|who+ps|whups|doh |d\'oh)" 40 "%VAR{ruins}" "en"
IMP_plugin_add_simple "bof" "^bof$" 30 [list "alors" "%VAR{FRENCH}"] "en"
IMP_plugin_add_simple "alors" "^alors$" 30 [list "bof" "%VAR{FRENCH}"] "en"
IMP_plugin_add_simple "bonjour" "bonjour" 20 "%VAR{FRENCH}" "en"
IMP_plugin_add_simple "foo" "^foo$" 30 "bar" "en"
IMP_plugin_add_simple "bar" "^bar$" 30 "foo" "en"
IMP_plugin_add_simple "moo" "^mooo*!*$" 40 "%VAR{moos}" "en"
IMP_plugin_add_simple ":(" "^((:|;|=)(\\\(|\\\[))$" 40 "%VAR{boreds}" "en"
IMP_plugin_add_simple "bored" "i'm bored" 40 "%VAR{boreds}" "en"
IMP_plugin_add_simple "transform" "^%botnicks:?,? transform and roll out" 100 [list "/transforms into %VAR{sillyThings} and rolls out"] "en"
IMP_plugin_add_simple "didn't!" "^i didn'?t!?$" 40 "%VAR{ididntresponses}" "en"
IMP_plugin_add_simple "ow" "^(ow+|ouch|aie+)!*$" 50 "%VAR{awwws}" "en"
#kis moved the following line to complex_questions because it was breaking stuff.
#kis IMP_plugin_add_simple "question-have" "^%botnicks:?,? do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" 100 "%VAR{yesnos}" "en"
IMP_plugin_add_simple "dude" "^Dude!$" 40 "%VAR{sweet}" "en"
IMP_plugin_add_simple "sweet" "^Sweet!$" 40 "%VAR{dude}" "en"
IMP_plugin_add_simple "asl-catch" {[0-9]+%slash[mf]%slash.+} 75 "%VAR{greetings}" "en"
IMP_plugin_add_simple "sing-catch" {^#.+#$} 40 [list "no singing%colen" "shh%colen"] "en"
IMP_plugin_add_simple "seven" {^7[?!.]?$} 40 [list "7!" "7 %VAR{smiles}" "wh%REPEAT{3:7:e} 7!"] "en"
IMP_plugin_add_simple "mmm" "mmm+ $botnicks" 80 "%VAR{smiles}" "en"
IMP_plugin_add_simple "no-mirc" "mirc" 40 [list "mIRC < xchat" "use xchat" "mmm xchat" "xchat > *" "/fires %% into the sun"] "en"
IMP_plugin_add_simple "no-bitchx" "bitchx" 40 [list "bitchx < xchat" "use xchat" "mmm xchat" "xchat > *" "/fires %% into the sun"] "en"
IMP_plugin_add_simple "no-trillian" "trillian" 40 [list "trillian < xchat" "use trillian + bitlbee" "mmm xchat" "xchat > *" "/fires %% into the sun"] "en"
