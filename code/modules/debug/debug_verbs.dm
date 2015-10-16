/client/verb/delete(var/datum/datum in view())
	set name = "Delete"
	if(istype(datum))
		qdel(datum)