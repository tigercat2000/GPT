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

	icon_state = "wkwalk"
	screen_loc = runwalk_loc

/obj/screen/speed/Click()
	if(istype(usr, /mob))
		usr.toggle_walk()
		update_icon(usr)

/obj/screen/speed/update_icon(mob/user)
	if(istype(user))
		if(user.walking)
			icon_state = "wkwalk"
		else icon_state = "wkrun"

/obj/screen/storage
	name = "storage"
	screen_loc = eitem_screen

	icon_state = "equipped_item"

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return 1
	if(master)
		var/obj/item/I = usr.get_equipped_item()
		if(I)
			master.attackby(I, usr, params)
	return 1

/obj/screen/drop
	name = "drop item"
	screen_loc = drop_loc

	icon_state = "drop_item"

/obj/screen/drop/Click(location, control, params)
	usr.drop_equipped_item()