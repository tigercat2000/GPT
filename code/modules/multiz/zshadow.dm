/mob  // TODO: rewrite as obj.
	var/mob/zshadow/shadow

/mob/zshadow
	plane = OVER_OPENSPACE_PLANE
	name = "shadow"
	desc = "Z-level shadow"
	anchored = 1
	density = 0
	opacity = 0					// Don't trigger lighting recalcs gah! TODO - consider multi-z lighting.
	var/mob/owner = null		// What we are a shadow of.

/mob/zshadow/can_fall()
	return FALSE

/mob/zshadow/New(var/mob/L)
	if(!istype(L))
		qdel(src)
		return
	..() // I'm cautious about this, but its the right thing to do.
	owner = L
	sync_icon(L)

/mob/Destroy()
	if(shadow)
		qdel(shadow)
		shadow = null
	. = ..()
/*
/mob/zshadow/examine(mob/user, distance, infix, suffix)
	return owner.examine(user, distance, infix, suffix)
*/
// Relay some stuff they hear
/mob/zshadow/hear_say(formatted_message, mob/speaker)
	if(speaker && speaker.z != src.z)
		return // Only relay speech on our acutal z, otherwise we might relay sounds that were themselves relayed up!
	return owner.hear_say(formatted_message, speaker)

/mob/zshadow/proc/sync_icon(var/mob/M)
	name = M.name
	icon = M.icon
	icon_state = M.icon_state
	//color = M.color
	color = "#848484"
	overlays = M.overlays
	transform = M.transform
	dir = M.dir
	if(shadow)
		shadow.sync_icon(src)

/mob/living/Move()
	. = ..()
	check_shadow()

/mob/living/forceMove()
	. = ..()
	check_shadow()

/mob/living/proc/check_shadow()
	var/mob/M = src
	if(isturf(M.loc))
		var/turf/simulated/open/OS = GetAbove(src)
		while(OS && istype(OS))
			if(!M.shadow)
				M.shadow = new /mob/zshadow(M)
			M.shadow.forceMove(OS)
			M = M.shadow
			OS = GetAbove(M)
	// The topmost level does not need a shadow!
	if(M.shadow)
		qdel(M.shadow)
		M.shadow = null

//
// Handle cases where the owner mob might have changed its icon or overlays.
//

/mob/living/update_icons()
	. = ..()
	if(shadow)
		shadow.sync_icon(src)

/mob/set_dir(new_dir)
	. = ..()
	if(shadow)
		shadow.set_dir(new_dir)

// Transfer messages about what we are doing to upstairs
/mob/visible_message(var/message, var/self_message, var/blind_message)
	. = ..()
	if(shadow)
		shadow.visible_message(message, self_message, blind_message)

