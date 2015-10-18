/turf
	icon = 'icons/turfs/turf.dmi'
	icon_state = "floor"

	var/dynamic_lighting = 1
	var/list/footstep_sounds = list()

/turf/New()
	. = ..()
	if(smooth)
		smooth_icon(src)

/turf/Destroy()
	. = ..()
	smooth_icon_neighbors(src)

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
/turf/proc/ChangeTurf(path)
	if(!path)			return
	if(path == type)	return src

	var/turf/W = new path(src)
	smooth_icon_neighbors(src)

	return W