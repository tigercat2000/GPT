/mob
	var/obj/item/equipped_item

/mob/proc/get_equipped_item()
	if(equipped_item)	return equipped_item

/mob/proc/update_inv_equipped()
	if(!client)
		return 0

	if(istype(hud_used) && !hud_used.hud_shown)
		return 1

	if(equipped_item)
		equipped_item.screen_loc = eitem_loc
		equipped_item.layer = 21
		client.screen |= equipped_item

/mob/proc/drop_equipped_item()
	if(equipped_item)
		unEquip(equipped_item)

/mob/proc/unEquip(obj/item/I)
	if(!I)
		return 1

	if(I == equipped_item)
		equipped_item = null
		update_inv_equipped()

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(loc)
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)

	return 1

/mob/proc/Equip(obj/item/I)
	if(equipped_item)
		return 0

	equipped_item = I
	I.forceMove(src)
	update_inv_equipped()

/mob/verb/AHO()
	set name = "Activate Held Object"
	set category = null
	set src = usr

	if(equipped_item)
		equipped_item.attack_self(src)
		update_inv_equipped()

/mob/verb/drop_equipped()
	set name = "dropequiped"
	set category = null
	set src = usr

	drop_equipped_item()