/obj/structure/rack
	name = "rack"
	icon_state = "rack"

/obj/structure/rack/special
	name = "altar"
	icon_state = "talismanaltar"
	anchored = 1
	density = 1
	light_range = 4
	light_color = "#FF9999"

/obj/structure/rack/special/attack_hand(mob/user)
	if(alert(user, "Would you like to summon a light?", "Summon.", "Yes", "No.") == "Yes")
		new /obj/following/light(loc, user)
	else
		user << "<span class='warning'>So be it.</span>"