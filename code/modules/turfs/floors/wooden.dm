/turf/wood
	name = "wood floor"
	icon_state = "wood"
	footstep_sounds = list('sound/effects/footstep_wood.ogg')
	appearance_flags = KEEP_TOGETHER
	var/cardinals = list()

/turf/wood/Initialize()
	for(var/sdir in cardinal)
		cardinals += sdir
		var/turf/spess/T = get_step(src, sdir)
		if(istype(T, /turf/spess))
			var/image/siding = image(icon, "wood_siding", dir = sdir)
			siding.plane = plane + 0.1
			siding.layer = layer + 1
			switch(siding.dir)
				if(NORTH)
					siding.pixel_y = world.icon_size
				if(SOUTH)
					siding.pixel_y = -world.icon_size
				if(EAST)
					siding.pixel_x = world.icon_size
				if(WEST)
					siding.pixel_x = -world.icon_size
			add_overlay(siding)


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