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