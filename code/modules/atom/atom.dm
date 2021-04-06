/atom
	var/initialized = FALSE

	var/list/our_overlays	//our local copy of (non-priority) overlays without byond magic. Use procs in SSoverlays to manipulate
	var/list/priority_overlays	//overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.

	// Bitflag fields
	/* flags_1: Currently used for
		- Nodrop
		- Overlay Processing
	*/
	var/flags_1 = NONE
	/* flags_2: Currently used for (nothing)*/
	var/flags_2 = NONE

	var/interaction_flags_atom = NONE

	plane = GAME_PLANE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER


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

/atom/New(loc, ...)
	var/do_initialize = SSatoms.initialized
	if(do_initialize > INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

	var/list/created = SSatoms.created_atoms
	if(created)
		created += src


//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize
// /mob/dead/new_player/Initialize

//Do also note that this proc always runs in New for /mob/dead
/atom/proc/Initialize(mapload, ...)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

/*
	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)
*/

	if(light_power && light_range)
		update_light()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	return

// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return

/atom/Destroy()
	invisibility = 101

	QDEL_NULL(light)

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

/atom/proc/set_dir(newdir)
	dir = newdir

/atom/proc/relaymove(mob/M, direct)
	return

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : get_turf(L)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/atom/proc/AllowDrop()
	return FALSE


/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(GetComponent(/datum/component/storage))
		return component_storage_contents_dump_act(src_object, user)
	return FALSE

/atom/proc/component_storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	while (do_after(user, 1 SECONDS, src, NONE, FALSE, CALLBACK(STR, /datum/component/storage.proc/handle_mass_item_insertion, things, src_object, user, progress)))
		stoplag(1)
	progress.end_progress()
	to_chat(user, "<span class='notice'>You dump as much of [src_object.parent]'s contents [STR.insert_preposition]to [src] as you can.</span>")
	STR.orient2hud(user)
	src_object.orient2hud(user)
	if(user.active_storage) //refresh the HUD to show the transfered contents
		user.active_storage.close(user)
		user.active_storage.show_to(user)
	return TRUE

/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	return
	//if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
	//	addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))
