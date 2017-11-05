/mob/New()
	. = ..()

	GLOB.mob_list |= src

/mob/Destroy()
	GLOB.mob_list -= src
	return QDEL_HINT_HARDDEL_NOW

/mob/proc/incapacitated()
	return 0