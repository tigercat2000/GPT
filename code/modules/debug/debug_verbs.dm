/client/verb/delete(var/datum/datum in view())
	set name = "Delete"
	set category = "Debug Verbs"
	if(istype(datum))
		qdel(datum)


/client/verb/aghost()
	set name = "aghost"
	if(!ghosting)
		if(mob)
			mob.see_in_dark = world.view
			mob.see_invisible = 100
			mob.sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
			mob.alpha = 127
		ghosting = 1
	else
		if(mob)
			mob.see_in_dark = initial(mob.see_in_dark)
			mob.see_invisible = initial(mob.see_invisible)
			mob.sight = initial(mob.sight)
			mob.alpha = 255
		ghosting = 0
