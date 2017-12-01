/turf/wood
	name = "wood floor"
	icon_state = "wood"
	footstep_sounds = list('sound/effects/footstep_wood.ogg')
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
	var/cardinals = list()

/turf/wood/missing
	name = "half wood floor"
	icon_state = "wood-missing"

//BROKEN
/turf/wood/broken
	icon_state = "wood-broken1"

/turf/wood/broken/rand/New() //RAND
	var/ico = rand(1, 7)
	icon_state = "wood-broken[ico]"

	..()


/turf/wood/broken/states/s1/icon_state = "wood-broken1"
/turf/wood/broken/states/s2/icon_state = "wood-broken2"
/turf/wood/broken/states/s3/icon_state = "wood-broken3"
/turf/wood/broken/states/s4/icon_state = "wood-broken4"
/turf/wood/broken/states/s5/icon_state = "wood-broken5"
/turf/wood/broken/states/s6/icon_state = "wood-broken6"
/turf/wood/broken/states/s7/icon_state = "wood-broken7"