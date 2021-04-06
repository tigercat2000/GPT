/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null

	appearance_flags = PIXEL_SCALE|NO_CLIENT_COLOR

/obj/screen/Destroy()
	master = null
	. = ..()

/obj/screen/speed
	name = "walking/running"

	icon_state = "wkrun"
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
	usr.drop_hand()

/obj/screen/throw
	name = "throw item"
	screen_loc = ui_throw

	icon_state = "throw_off"

/obj/screen/throw/Click(location, control, params)
	if(usr.in_throw_mode)
		usr.throw_mode_off()
	else
		usr.throw_mode_on()

/obj/screen/throw/update_icon(mob/user)
	if(istype(user))
		if(user.in_throw_mode)
			icon_state = "throw_on"
		else
			icon_state = "throw_off"

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	layer = HUD_LAYER

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	usr.attack_ui(slot_id)
	//if(usr.attack_ui(slot_id))
		//usr.update_inv_l_hand(0)
		//usr.update_inv_r_hand(0)
	return 1

/obj/screen/inventory/hand
	var/image/active_overlay

/obj/screen/inventory/hand/update_icon()
	..()
	if(!active_overlay)
		active_overlay = image("icon"=icon, "icon_state"="hand_active")

	overlays.Cut()

	if(hud && hud.mymob)
		if(slot_id == INV_L_HAND && hud.mymob.active_hand_slot == INV_L_HAND)
			overlays += active_overlay
		else if(slot_id == INV_R_HAND && hud.mymob.active_hand_slot == INV_R_HAND)
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
		switch(slot_id)
			if(INV_R_HAND)
				M.change_active_hand(INV_R_HAND)
			if(INV_L_HAND)
				M.change_active_hand(INV_L_HAND)
	return 1


/obj/screen/grab
	name = "grab"
	icon = 'icons/mob/screen_gen.dmi'

/obj/screen/grab/Click()
	var/obj/item/weapon/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "backpack_close"

/obj/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/close/Click()
	var/datum/component/storage/S = master
	S.hide_from(usr)
	return TRUE

/obj/screen/storage
	name = "storage"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.stat) // todo
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(src, I, usr, params)
	return TRUE