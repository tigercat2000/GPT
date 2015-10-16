/proc/get_turf(atom/A)
	if (!istype(A))
		return
	for(A, A && !isturf(A), A=A.loc); //semicolon is for the empty statement
	return A

/proc/subtypesof(var/path) //Returns a list containing all subtypes of the given path, but not the given path itself.
	if(!path || !ispath(path))
		CRASH("Invalid path, failed to fetch subtypes of \"[path]\".")
	return (typesof(path) - path)


var/mob/dview/dview_mob = new

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

/mob/dview
	invisibility = 101
	density = 0

	see_in_dark = 1e6

/mob/dview/New() //For whatever reason, if this isn't called, then BYOND will throw a type mismatch runtime when attempting to add this to the mobs list. -Fox

/proc/IsValidSrc(var/A)
	if(istype(A, /datum))
		var/datum/B = A
		return isnull(B.gcDestroyed)
	if(istype(A, /client))
		return 1
	return 0