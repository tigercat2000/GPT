/mob/New()
	. = ..()

	mob_list |= src


/mob/Destroy()
	mob_list -= src
	return QDEL_HINT_HARDDEL_NOW