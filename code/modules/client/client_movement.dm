/client
	var/move_delay = null

/client/Move(n, direct)
	if(world.time < move_delay)
		return

	move_delay = world.time
	move_delay += mob.movement_delay()
	. = ..()


//restrictions
/client/Northeast() return
/client/Northwest() return
/client/Southeast() return
/client/Southwest() return

/mob/proc/Move_Pulled(atom/A)
	if(!pulling)
		return
	if(!pulling.Adjacent(src))
		return
	if(A == loc && pulling.density)
		return

	if(ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(pulling, get_dir(pulling.loc, A))
		if(M)
			M.start_pulling(t)
	else
		step(pulling, get_dir(pulling.loc, A))