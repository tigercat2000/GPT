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
	interact(user)

/*	if(alert(user, "Would you like to summon a light?", "Summon.", "Yes", "No.") == "Yes")
		var/obj/following/light/L = new(loc, user)
		L.color = "#FF0000"
		L.light_color = "#FF7777"
	else
		to_chat(user, "<span class='warning'>So be it.</span>")*/

/obj/structure/rack/special/proc/interact(mob/user)
	var/dat = ""
	dat += "<a href='?src=\ref[src];summon=light'>Summon Light</a>"

	var/datum/browser/popup = new(user, "altar", "Altar", 240, 240)
	popup.set_content(dat)
	popup.open()

/obj/structure/rack/special/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	if(!istype(user))
		return 0

	switch(href_list["summon"])
		if("light")
			var/obj/following/light/L = new(loc, usr)
			L.color = "#FF0000"
			L.light_color = "#FF7777"
			L.alpha = 0
			animate(L, alpha = 255, time = 2)