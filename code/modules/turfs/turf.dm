/var/list/turf/turfs = list()

/turf
	name = "floor"
	icon = 'icons/turfs/turf.dmi'
	icon_state = "floor"
	plane = PLANE_TURF

	var/list/footstep_sounds = list()

/turf/New()
	. = ..()
	if(smooth)
		smooth_icon(src)

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
	var/old_lighting_overlay = lighting_overlay
	var/old_corners = corners

	var/turf/W = new path(src)
	smooth_icon_neighbors(src)

	. = W

	lighting_corners_initialised = TRUE
	recalc_atom_opacity()
	lighting_overlay = old_lighting_overlay
	affecting_lights = old_affecting_lights
	corners = old_corners
	if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
		reconsider_lights()

	if(dynamic_lighting != old_dynamic_lighting)
		if(dynamic_lighting)
			lighting_build_overlay()
		else
			lighting_clear_overlay()
