/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = 20
	var/obj/master

/obj/screen/Destroy()
	master = null
	. = ..()

/obj/screen/speed
	name = "walking/running"

	icon_state = "wkrun"
	screen_loc = "1,1"

/obj/screen/speed/Click()
	if(istype(usr, /mob))
		usr.toggle_walk()