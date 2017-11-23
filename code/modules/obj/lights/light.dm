/obj/light
	light_range = 5
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube0"
	anchored = 1

	var/on = 1
	var/on_state = "tube1"

/obj/light/New()
	. = ..()
	update_range()

/obj/light/proc/change_state()
	on = !on
	update_range()

/obj/light/proc/update_range()
	if(on)
		light_range = initial(light_range)
		icon_state = on_state
	else
		light_range = 0
		icon_state = initial(icon_state)
	update_light()

/obj/light/street_post
	name = "Lamppost"
	icon = 'icons/obj/lamppost_32.dmi'
	icon_state = "lamppost0"
	on_state = "lamppost1"
	density = 1

	light_range = 6
	light_color = "#a0a080"

	layer = ABOVE_MOB_LAYER
