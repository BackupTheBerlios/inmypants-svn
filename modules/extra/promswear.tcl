###############################################################################
# This is a IMP module
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_abstract_register "prom_first"
IMP_abstract_batchadd "prom_first" [list "arse" "cack" "piss" "shit" "fuck" "turd" "minge" "crap" "vadge" "shat" "clit" "cum" "wank" "flid"]

IMP_abstract_register "prom_second"
IMP_abstract_batchadd "prom_second" [list "puma" "whistle" "shaver" "glass" "flute" "rifle" "flower" "desk" "curtain" "wheel" "door" "coin" "speaker" "lamp" "radio" "twix" "action" "account" "pump" "tea" "pot" "square" "robe" "apple" "cave" "lantern" "drawer" "card" "pants"]

IMP_abstract_register "PROM"
IMP_abstract_add "PROM" "%VAR{prom_first}-%VAR{prom_second}"
