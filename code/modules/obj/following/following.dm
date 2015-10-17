//FOLLOWING
/obj/following
	name = "Following Object"
	icon_state = "rack"

	var/min_follow_distance = 2

/obj/following/New(loc, target)
	. = ..()
	if(target)
		walk_to(src, target, min_follow_distance, 1, 0)


/obj/following/light
	name = "floating light"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor1"

	light_range = 5
	light_power = 2