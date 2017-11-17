/mob/New()
	. = ..()

	GLOB.mob_list |= src

/mob/Destroy()
	GLOB.mob_list -= src
	return QDEL_HINT_HARDDEL_NOW

/mob/proc/incapacitated()
	return 0

/mob/proc/ghostize()
	if(!ckey)
		return
	var/mob/ghost/G = new(loc, src)
	G.ckey = ckey
	G.name = name + " (ghost)"

	var/mutable_appearance/our_appearance = new(src)
	our_appearance.alpha = 127
	our_appearance.plane = PLANE_GAME
	G.appearance = our_appearance