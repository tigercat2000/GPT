/obj/landmark
	name = "landmark"

/obj/landmark/New()
	. = ..()
	tag = "landmark*[name]"
	invisibility = 101

/obj/landmark/start
	name = "start"

/obj/landmark/start/New()
	..()

	starting_pos += loc
	qdel(src)