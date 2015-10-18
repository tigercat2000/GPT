/atom/movable
	var/anchored = 0
	var/atom/movable/pulledby = null

// Previously known as Crossed()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/A)
	if(A)
		A.Bumped(src)

	. = ..()

/atom/movable/Destroy()
	. = ..()
	loc = null

/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		var/area/A = get_area(loc)
		if(istype(A)) A.Entered(src)

		for(var/atom/movable/AM in loc)
			AM.Crossed(src)
		return 1
	return 0