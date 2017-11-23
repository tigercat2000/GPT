
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
			mob.forceMove(T)
			mob.set_dir(direct)
			return 1

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(Process_Grab())
		return

	var/list/grabs = mob.grabbed()
	if(islist(grabs) && grabs.len > 0)
		move_delay = max(move_delay, world.time + 7)
		var/turf/T = mob.loc
		. = ..()

		for(var/obj/item/weapon/grab/G in grabs)
			var/mob/M = G.affecting
			if(ismob(M) && isturf(M.loc))
				var/diag = get_dir(mob, M)
				if((diag - 1) & diag)
				else diag = null
				if(get_dist(mob, M) > 1 || diag)
					step(M, get_dir(M.loc, T))
	else
		. = ..()

	for(var/obj/item/weapon/grab/G in mob)
		if(G.state == GRAB_NECK)
			mob.set_dir(GLOB.reverse_dir[direct])
		G.adjust_position()
	for(var/obj/item/weapon/grab/G in mob.grabbed_by)
		G.adjust_position()


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

/client/proc/Process_Grab()
	if(mob.grabbed_by.len)
		var/list/grabbing = mob.grabbed_mobs()
		for(var/X in mob.grabbed_by)
			var/obj/item/weapon/grab/G = X
			switch(G.state)
				if(GRAB_PASSIVE)
					if(!grabbing.Find(G.assailant))
						qdel(G)

				if(GRAB_AGGRESSIVE)
					move_delay = world.time + 10
					if(!prob(25))
						return 1
					mob.visible_message("<span class='danger'>[mob] has broken free of [G.assailant]'s grip!</span>")
					qdel(G)

				if(GRAB_NECK)
					move_delay = world.time + 10
					if(!prob(5))
						return 1
					mob.visible_message("<span class='danger'>[mob] has broken free of [G.assailant]'s headlock!</span>")
					qdel(G)
	return 0
#undef DO_MOVE