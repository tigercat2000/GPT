/var/list/turf/turfs = list()

/turf
	name = "floor"
	icon = 'icons/turfs/turf.dmi'
	icon_state = "floor"
	plane = FLOOR_PLANE

	var/list/footstep_sounds = list()

/turf/New()
	. = ..()
	if(smooth)
		smooth_icon(src)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	global.turfs += src

/turf/Destroy()
	. = ..()
	smooth_icon_neighbors(src)

	global.turfs -= src

/turf/Enter(atom/movable/mover, atom/forget)
	if(!mover)
		return 1

	if(isturf(mover.loc))
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				return 0

	var/list/large_dense = list()
	for(var/atom/movable/border_obstacle in src)
		large_dense += border_obstacle

	if(!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc) && (forget != obstacle))
			return 0
	return 1

/turf/CanPass(atom/movable/mover, turf/target)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

/turf/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()

	if(prob(35) && ismob(AM) && footstep_sounds.len)
		var/mob/M = AM
		var/picked_sound = pick(footstep_sounds)
		if(M.walking)
			playsound(AM, picked_sound, 30, 1)
		else
			playsound(AM, picked_sound, 60, 1)

//Creates a new turf
/turf/proc/ChangeTurf(path, tell_universe = 1, force_lighting_update = 0)
	if(!path)			return
	if(path == type)	return src

	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_corners = corners

	var/turf/W = new path(src)
	smooth_icon_neighbors(src)

	W.AfterChange()
	. = W
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, W)

	lighting_corners_initialised = TRUE
	recalc_atom_opacity()
	lighting_object = old_lighting_object
	affecting_lights = old_affecting_lights
	corners = old_corners
	if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
		reconsider_lights()

	if(dynamic_lighting != old_dynamic_lighting)
		if(IS_DYNAMIC_LIGHTING(src))
			lighting_build_overlay()
		else
			lighting_clear_overlay()

// Called after turf replaces old one
/turf/proc/AfterChange()
	var/turf/simulated/open/T = GetAbove(src)
	if(istype(T))
		T.update_icon()

/turf/proc/empty(turf_type=RESERVED_TURF_TYPE, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/* /mob/dead, /obj/effect/landmark, /obj/docking_port,  *//atom/movable/lighting_object))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		/* var/turf/newT =  */ChangeTurf(turf_type, baseturf_type, flags)
		// SSair.remove_from_active(newT)
		// CALCULATE_ADJACENT_TURFS(newT, KILL_EXCITED)