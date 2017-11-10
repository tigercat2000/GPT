GLOBAL_VAR_INIT(open_space_initialized, FALSE)
GLOBAL_REAL(over_OS_darkness, /image) = image('icons/turfs/open_space.dmi', "black_open")

SUBSYSTEM_DEF(openspace)
	name = "openspace"
	priority = 17
	wait = 1
	var/list/processing = list()

/datum/controller/subsystem/openspace/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/openspace/Initialize()
	over_OS_darkness.plane = OVER_OPENSPACE_PLANE
	over_OS_darkness.layer = MOB_LAYER
	initialize_open_space()

/datum/controller/subsystem/openspace/fire(resumed = 0)
	while(processing.len)
		var/turf/T = processing[processing.len]
		processing.len--
		if(istype(T))
			update_turf(T)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/openspace/proc/update_turf(turf/T)
	for(var/atom/movable/A in T)
		A.fall()
	T.update_icon()

/datum/controller/subsystem/openspace/proc/add_turf(turf/T, recursive = 0)
	ASSERT(isturf(T))
	processing += T
	if(recursive > 0)
		var/turf/above = GetAbove(T)
		if(above && isopenspace(above))
			add_turf(above, recursive)

/datum/controller/subsystem/openspace/proc/initialize_open_space()
	for(var/zlevel = 1 to world.maxz)
		for(var/turf/simulated/open/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
			add_turf(T)
	GLOB.open_space_initialized = TRUE

/* Hooks */

/turf/simulated/open/Initialize()
	. = ..()
	if(GLOB.open_space_initialized)
		// log_debug("[src] ([x],[y],[z]) queued for update for initialize()")
		SSopenspace.add_turf(src)

/turf/Entered(atom/movable/AM)
	. = ..()
	if(GLOB.open_space_initialized && !AM.invisibility && isobj(AM))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].Entered([AM])")
			SSopenspace.add_turf(T, 1)

/turf/Exited(atom/movable/AM)
	. = ..()
	if(GLOB.open_space_initialized && !AM.invisibility && isobj(AM))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].Exited([AM])")
			SSopenspace.add_turf(T, 1)

/obj/update_icon()
	. = ..()
	if(GLOB.open_space_initialized && !invisibility && isturf(loc))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].update_icon()")
			SSopenspace.add_turf(T, 1)

// Just as New() we probably should hook Destroy() If we can think of something more efficient, lets hear it.
/obj/Destroy()
	if(GLOB.open_space_initialized && !invisibility && isturf(loc))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			SSopenspace.add_turf(T, 1)
	. = ..() // Important that this be at the bottom, or we will have been moved to nullspace.
