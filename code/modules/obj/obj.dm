/obj
	icon = 'icons/obj/obj.dmi'

/obj/proc/process()
	return 0



/obj/structure
	name = "structure"

/obj/structure/rack
	name = "rack"
	icon_state = "rack"

/obj/structure/rack/special
	name = "altar"
	icon_state = "talismanaltar"
	anchored = 1
	light_range = 3
	light_color = "#FFAAAA"

/obj/structure/rack/special/attack_hand(mob/user)
	if(alert(user, "Would you like to summon a light?", "Summon.", "Yes", "No.") == "Yes")
		new /obj/following/light(loc, user)
	else
		user << "<span class='warning'>So be it.</span>"


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