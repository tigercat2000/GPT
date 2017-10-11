/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = LAYER_HUD
	plane = PLANE_HUD
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null

	appearance_flags = NO_CLIENT_COLOR

/obj/screen/Destroy()
	master = null
	. = ..()

/obj/screen/speed
	name = "walking/running"

	icon_state = "wkwalk"
	screen_loc = ui_mov_sel

/obj/screen/speed/Click()
	if(ismob(usr))
		usr.toggle_walk()
		update_icon(usr)

/obj/screen/speed/update_icon(mob/user)
	if(istype(user))
		if(user.walking)
			icon_state = "wkwalk"
		else icon_state = "wkrun"

/obj/screen/drop
	name = "drop item"
	screen_loc = ui_drop

	icon_state = "drop_item"

/obj/screen/drop/Click(location, control, params)
	usr.drop_item()

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	layer = 19

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if(usr.attack_ui(slot_id))
		usr.update_inv_l_hand(0)
		usr.update_inv_r_hand(0)
	return 1

/obj/screen/inventory/hand
	var/image/active_overlay

/obj/screen/inventory/hand/update_icon()
	..()
	if(!active_overlay)
		active_overlay = image("icon"=icon, "icon_state"="hand_active")

	overlays.Cut()

	if(hud && hud.mymob)
		if(slot_id == slot_l_hand && hud.mymob.hand)
			overlays += active_overlay
		else if(slot_id == slot_r_hand && !hud.mymob.hand)
			overlays += active_overlay

/obj/screen/inventory/hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1

	if(ismob(usr))
		var/mob/M = usr
		switch(name)
			if("right hand", "r_hand")
				M.activate_hand("r")
			if("left hand", "l_hand")
				M.activate_hand("l")
	return 1