/mob/ghost
	alpha = 127
	density = 0
	see_in_dark = 5
	see_invisible = 100
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	var/mob/real_mob

/mob/ghost/New(loc, mob)
	. = ..()
	real_mob = mob

	verbs -= /mob/verb/stop_pulling
	verbs -= /mob/verb/pulled
	verbs -= /mob/verb/toggle_walk_verb

/mob/ghost/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ghost(src)

/mob/ghost/can_equip()
	return FALSE // ghosts cannot hold anything


/mob/ghost/say_broadcast(formatted_message)
	formatted_message = "<span class='deadsay'>[formatted_message]</span>"
	for(var/mob/ghost/G in GLOB.players)
		G.hear_say(formatted_message, src)


/mob/ghost/proc/reenter_corpse()
	if(ismob(real_mob))
		real_mob.ckey = ckey
		qdel(src)
	else
		to_chat(src, "<span class='warning'>You have no body to reenter!</span>")

/mob/ghost/movement_delay()
	return 0.5

/mob/ghost/DblClickOn(atom/A)
	loc = get_turf(A)

/mob/ghost/MouseDrop(atom/over_object, atom/src_location, atom/over_location)
	if(ismob(over_object) && isadmin(client))
		if(real_mob)
			real_mob.ckey = null
		var/mob/M = over_object
		M.ghostize()
		M.ckey = ckey
		qdel(src)