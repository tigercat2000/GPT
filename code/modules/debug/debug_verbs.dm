/client/verb/delete(var/datum/datum in view())
	set name = "Delete"
	set category = "Debug Verbs"
	if(istype(datum))
		qdel(datum)