
#define DO_MOVE(this_dir) var/final_dir = turn(this_dir, -dir2angle(dir)); Move(get_step(mob, final_dir), final_dir);
// The byond version of these verbs wait for the next tick before acting.
// instant verbs however can run mid tick or even during the time between ticks.
/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	DO_MOVE(NORTH)

/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	DO_MOVE(SOUTH)

/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	DO_MOVE(EAST)

/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	DO_MOVE(WEST)

/client
	var/move_delay = null

/client/Move(n, direct)
	if(world.time < move_delay)
		return

	move_delay = world.time
	move_delay += mob.movement_delay()

	if(!mob.canmove)
		return 0

	if(istype(mob, /mob/ghost))
		var/turf/T = get_step(mob, direct)
		if(T)
			mob.loc = T
			mob.set_dir(direct)
			return 1

	. = ..()


//restrictions
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

#undef DO_MOVE