# Delilah's crap plugin (avec sim-help)

set random_crap_adj {
	"blue"
	"yellow"
	"lemon-flavoured"
	"monstar"
	"shiny"
	"tall"
	"furry"
	"loud"
	"warm"
	"stinky"
	"tasty"
}

set random_crap_type {
	"poop"
	"crap"
	"shit"
	"turd"
	"log"
	"dropping"
	"doodoo"
	"dudu"
	"poo"
	"number 2"
	"dump"
	"klingon"
	"dingleberry"
	"dollop"
}

proc IMP_plugin_complex_crap { nick host handle channel text } {
	#IMP_flood_undo $nick

	# regexp -nocase "^!crap (.+)" $text matches command text

	IMP_putloglev d * "IMP: i have been made all crappy by $nick"

	global random_crap_adj random_crap_type
	set adj [ pickRandom $random_crap_adj ]
	set type [ pickRandom $random_crap_type ]

	set phrase "/does a $adj $type and hands it to %ruser"
	IMPDoAction $channel $nick $phrase
}

# register callbacks
IMP_plugin_add_complex "crap" "^!crap" 100 "IMP_plugin_complex_crap" "en"

