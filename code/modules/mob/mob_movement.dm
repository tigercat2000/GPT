/mob/Move(atom/newloc, direct)
	if(pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
		var/turf/T = loc
		. = ..()

		if(pulling && pulling.loc)
			if(!isturf(pulling.loc))
				stop_pulling()
				return

		if(pulling && pulling.anchored)
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

/mob/proc/movement_delay()
	var/tally = movement_delay
	if(walking)
		tally += 2

	return tally

/mob/proc/toggle_walk()
	walking = !walking
	to_chat(src, "<span class='notice'>You are now [walking ? "walking" : "running"].</span>")

	for(var/obj/screen/speed/S in hud_used.static_inventory)
		S.update_icon(src)
