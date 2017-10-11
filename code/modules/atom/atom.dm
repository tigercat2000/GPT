/atom
	var/flags = 0

/atom/proc/Bumped(atom/AM)
	return

/atom/proc/CheckExit()
	return 1

/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

/atom/proc/visible_message(var/message)
	for(var/mob/M in viewers(src))
		to_chat(M, message)

/mob/visible_message(var/message, var/self_message)
	if(!self_message)
		. = ..()
	else
		to_chat(src, self_message)
		for(var/mob/M in viewers(src) - src)
			to_chat(M, message)

/atom/Destroy()
	invisibility = 101
	. = ..()

/atom/proc/update_icon()
	return 0


//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		/*if(istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++*/
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		/*if(istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++*/
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth