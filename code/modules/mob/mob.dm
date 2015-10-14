/mob
	icon = 'icons/mob/mob.dmi'
	icon_state = "human"

/mob/proc/movement_delay()
	return movement_delay

/mob/Move(atom/newloc, direct)
	if(pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
		var/turf/T = loc
		. = ..()

		if(pulling && pulling.loc)
			if(!isturf(pulling.loc))
				stop_pulling()
				return

		var/diag = get_dir(src, pulling)
		if((diag - 1) & diag);
		else diag = null

		if((get_dist(src, pulling) > 1 || diag))
			if(pulling)
				pulling.Move(T, get_dir(pulling, T))

	else
		stop_pulling()
		. = ..()


/mob/SPOOKY
	name = "SPOOKYSHIT"

/mob/SPOOKY/Bumped(atom/A)
	if(ismob(A))
		follow_someone(A)

/mob/SPOOKY/proc/follow_someone(mob/M)
	if(!istype(M))	return 0
	walk_towards(src, M, 3, 3)

/mob/SPOOKY/attack_hand(mob/user)
	say("HELP")