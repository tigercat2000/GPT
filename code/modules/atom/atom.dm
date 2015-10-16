/atom/proc/Bumped(atom/AM)
	return

/atom/proc/CheckExit()
	return 1

/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

/atom/proc/visible_message(var/message)
	for(var/mob/M in viewers(src))
		M << message

/mob/visible_message(var/message, var/self_message)
	for(var/mob/M in viewers(src))
		if(M == src)
			M << self_message
		else	..()

/atom/Destroy()
	..()
	return QDEL_HINT_QUEUE