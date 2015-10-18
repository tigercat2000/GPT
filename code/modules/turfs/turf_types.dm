/turf/wood
	name = "wood floor"
	icon_state = "wood"
	footstep_sounds = list('sound/effects/footstep_wood.ogg')

/turf/wood/missing
	name = "half wood floor"
	icon_state = "wood-missing"

/turf/spess
	name = "space"
	icon = 'icons/turfs/space.dmi'
	icon_state = "0"

	dynamic_lighting = 0
	luminosity = 1

	density = 1

/turf/spess/New()
	. = ..()
	icon_state = "[rand(0,25)]"