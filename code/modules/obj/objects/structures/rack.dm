/obj/structure/rack
	name = "rack"
	icon = 'icons/obj/obj.dmi'
	icon_state = "rack"

/obj/structure/rack/special
	name = "altar"
	icon_state = "talismanaltar"
	anchored = 1
	density = 1
	light_range = 4
	light_color = "#FF9999"

/obj/structure/rack/special/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/rack/special/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Altar")
		ui.open()

/obj/structure/rack/special/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("light")
			var/obj/following/light/L = new(loc, usr)
			L.color = "#FF0000"
			L.light_color = "#FF7777"
			L.alpha = 0
			animate(L, alpha = 255, time = 2)
			return TRUE