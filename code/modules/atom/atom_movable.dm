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
	//unbuckle_all_mobs(force=1)

	. = ..()
	if(loc)
		loc.handle_atom_del(src)

	for(var/atom/movable/AM in contents)
		qdel(AM)

	moveToNullspace()
	
	if(pulledby)
		pulledby.stop_pulling()

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
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir)
	return 1


// called when this atom is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/atom/movable/proc/on_exit_storage(datum/component/storage/concrete/S)
	return

// called when this atom is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/atom/movable/proc/on_enter_storage(datum/component/storage/concrete/S)
	return