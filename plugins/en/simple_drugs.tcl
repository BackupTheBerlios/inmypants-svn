## IMP simple plugin: drugs
# DRUGS ARE BAD, MMKAY

###############################################################################
# This is a IMP plugin
# Copyright (C) Dave Wickham 2004
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_simple "drugs" "(I|we|I've|we've|you've) (got|have|want|scored|need) (some|any)? (weed|wacky backy|extacy|lsd|dope|cannabis|resin|ganja|hash|hashish|morphine|heroin|diamorphine|crack|cocaine).*" 100 "%VAR{dontDoDrugs}" "en"
