/turf/proc/CanZPass(atom/A, direction)
	if(z == A.z) //moving FROM this turf
		return direction == UP //can't go below
	else
		if(direction == UP) //on a turf below, trying to enter
			return 0
		if(direction == DOWN) //on a turf above, trying to enter
			return !density && isopenspace(GetAbove(src)) // VOREStation Edit

/turf/simulated/open/CanZPass(atom, direction)
	return 1

//
// Open Space - "empty" turf that lets stuff fall thru it to the layer below
//

/turf/simulated/open
	name = "open space"
	icon = 'icons/turfs/space.dmi'
	icon_state = ""
	desc = "\..."
	density = 0
	plane = OPENSPACE_PLANE_START
	dynamic_lighting = 0 // Someday lets do proper lighting z-transfer.  Until then we are leaving this off so it looks nicer.

	var/turf/below

/turf/simulated/open/post_change()
	..()
	update()

/turf/simulated/open/Initialize()
	..()
	ASSERT(HasBelow(z))
	update()

/turf/simulated/open/Entered(var/atom/movable/mover)
	. = ..()
	mover.fall()

/turf/simulated/open/proc/update()
	plane = OPENSPACE_PLANE + src.z
	below = GetBelow(src)
	below.AddComponent(/datum/component/turfchange, src)
	for(var/atom/movable/A in src)
		A.fall()
	SSopenspace.add_turf(src, 1)

/*/turf/simulated/open/examine(mob/user, distance, infix, suffix)
	if(..(user, 2))
		var/depth = 1
		for(var/T = GetBelow(src); isopenspace(T); T = GetBelow(T))
			depth += 1
		to_chat(user, "It is about [depth] levels deep.")*/

/**
* Update icon and overlays of open space to be that of the turf below, plus any visible objects on that turf.
*/
/turf/simulated/open/update_icon()
	overlays = list() // Edit - Overlays are being crashy when modified.
	//update_icon_edge()// Add - Get grass into open spaces and whatnot.
	var/turf/below = GetBelow(src)
	if(below)
		var/below_is_open = isopenspace(below)

		if(below_is_open)
			underlays = below.underlays
		else
			var/image/bottom_turf = image(icon = below.icon, icon_state = below.icon_state, dir=below.dir, layer=below.layer)
			bottom_turf.plane = src.plane
			bottom_turf.color = below.color
			underlays = list(bottom_turf)
		// Hack workaround to byond crash bug - Include the magic overlay holder object.
		overlays += below.overlays
		// if(below.overlay_holder)
		// 	overlays += (below.overlays + below.overlay_holder.overlays)
		// else
		// 	overlays += below.overlays

		// get objects (not mobs, they are handled by /obj/zshadow)
		var/list/o_img = list()
		for(var/obj/O in below)
			if(O.invisibility) continue // Ignore objects that have any form of invisibility
			if(O.loc != below) continue // Ignore multi-turf objects not directly below
			var/image/temp2 = image(O, dir = O.dir, layer = O.layer)
			temp2.plane = src.plane
			temp2.color = O.color
			temp2.overlays += O.overlays
			// TODO Is pixelx/y needed?
			o_img += temp2
		var/overlays_pre = overlays.len
		overlays += o_img
		var/overlays_post = overlays.len
		if(overlays_post != (overlays_pre + o_img.len)) //Here we go!
			world.log << "Corrupted openspace turf at [x],[y],[z] being replaced. Pre: [overlays_pre], Post: [overlays_post]"
			new /turf/simulated/open(src)
			return //Let's get out of here.

		if(!below_is_open)
			overlays += over_OS_darkness

		return 0
	return PROCESS_KILL
