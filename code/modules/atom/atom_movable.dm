/atom/movable
	var/anchored = 0
	var/mob/pulledby = null
	appearance_flags = PIXEL_SCALE
	//glide_size = 8

// Previously known as Crossed()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/A)
	if(A)
		A.Bumped(src)

	. = ..()

/atom/movable/Destroy()
	for(var/atom/movable/AM in contents)
		qdel(AM)
	loc = null
	if(pulledby)
		if(pulledby.pulling == src)
			pulledby.pulling = null
		pulledby = null
	..()
	return QDEL_HINT_QUEUE

/*** MOVEMENT ***/

/atom/movable/Move(atom/newloc, direct = 0)
	if(!loc || !newloc)
		return 0
	var/atom/oldloc = loc

	. = ..()
	set_dir(direct)

	if(.)
		Moved(oldloc, direct)


/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")


/atom/movable/proc/moveToNullspace()
	return doMove(null)


/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/atom/oldloc = loc
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		if(oldloc && !same_loc)
			oldloc.Exited(src, destination)
			if(old_area)
				old_area.Exited(src, destination)

		loc = destination

		if(!same_loc)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, oldloc)

			for(var/atom/movable/AM in destination)
				if(AM == src)
					continue
				AM.Crossed(src, oldloc)

		Moved(oldloc, 0)
		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE
		var/atom/oldloc = loc
		var/area/old_area = get_area(oldloc)
		oldloc.Exited(src, null)
		if(old_area)
			old_area.Exited(src, null)
		loc = null

//Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir)
	SendSignal(COMSIG_MOVABLE_MOVED, OldLoc, Dir)
	return 1