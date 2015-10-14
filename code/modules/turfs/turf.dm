/turf
	icon = 'icons/turfs/turf.dmi'
	icon_state = "floor"

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