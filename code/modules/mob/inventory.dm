/mob
	var/obj/item/l_hand = null
	var/obj/item/r_hand = null
	var/obj/item/store = null

	var/obj/item/w_uniform = null
	var/obj/item/w_shoes = null

	var/hand = null


//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)
		return l_hand
	else
		return r_hand

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)
		return r_hand
	else
		return l_hand

//Returns if a certain item can be equipped to a certain slot.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = 0)
	switch(slot)
		if(slot_l_hand)
			if(l_hand)
				return 0
			return 1
		if(slot_r_hand)
			if(r_hand)
				return 0
			return 1
		if(slot_store)
			if(store)
				return 0
			if(!(slot_store in I.slot_list))
				return 0
			return 1
	return 0

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(var/obj/item/W)
	return equip_to_slot_if_possible(W, slot_l_hand)

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(var/obj/item/W)
	return equip_to_slot_if_possible(W, slot_r_hand)

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(var/obj/item/W)
	if(hand)
		return put_in_l_hand(W)
	else
		return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(var/obj/item/W)
	if(hand)
		return put_in_r_hand(W)
	else
		return put_in_l_hand(W)

//Drops the item in our left hand
/mob/proc/drop_l_hand()
	return unEquip(l_hand) //All needed checks are in unEquip

//Drops the item in our right hand
/mob/proc/drop_r_hand()
	return unEquip(r_hand) //Why was this not calling unEquip in the first place jesus fuck.

//Drops the item in our active hand.
/mob/proc/drop_item() //THIS. DOES. NOT. NEED. AN. ARGUMENT.
	if(hand)
		return drop_l_hand()
	else
		return drop_r_hand()


//Here lie unEquip and before_item_take, already forgotten and not missed.
/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return 1
	if((I.flags_1 & NODROP_f1) && !force)
		return 0
	return 1

/mob/proc/unEquip(obj/item/I, force) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!canUnEquip(I, force))
		return 0


	var/slot = get_slot(I)

	update_slot(slot)
	update_slot_icon(slot)

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(loc)
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)
			I.plane = initial(I.plane)
	return 1

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

/mob/proc/get_slot(obj/item/I)
	if(!I)
		return null

	if(I == l_hand)
		return slot_l_hand
	if(I == r_hand)
		return slot_r_hand
	if(I == store)
		return slot_store
	if(I == w_uniform)
		return slot_w_uniform
	if(I == w_shoes)
		return slot_w_shoes

	return null

/mob/proc/update_slot(slot, obj/item/I = null)
	switch(slot)
		if(slot_l_hand)
			l_hand = I ? I : null
		if(slot_r_hand)
			r_hand = I ? I : null
		if(slot_store)
			store = I ? I : null
		if(slot_w_uniform)
			w_uniform = I ? I : null
		if(slot_w_shoes)
			w_shoes = I ? I : null

/mob/proc/update_slot_icon(slot)
	switch(slot)
		if(slot_l_hand)
			update_inv_l_hand()
		if(slot_r_hand)
			update_inv_r_hand()
		if(slot_store)
			update_inv_store()
		if(slot_w_uniform)
			update_inv_w_uniform()
		if(slot_w_shoes)
			update_inv_w_shoes()

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()

	if(istype(W))
		equip_to_slot_if_possible(W, slot)
	else
		W = get_item_by_slot(slot)
		if(W)
			W.attack_hand(src)

//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, del_on_fail = 0, disable_warning = 0)
	if(!istype(W))
		return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, "<span class='warning'>You are unable to equip that.</span>")

		return 0

	equip_to_slot(W, slot)
	return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W, slot)
	if(!slot)
		return

	if(!istype(W))
		return


	var/curr_slot = get_slot(W)

	if(curr_slot)
		update_slot(curr_slot)
		update_slot_icon(curr_slot)

	W.screen_loc = null
	W.forceMove(src)
	W.equipped(src, slot)
	W.layer = LAYER_HUD + 1
	W.plane = PLANE_HUD
	if(pulling == W)
		stop_pulling()

	update_slot(slot, W)
	update_slot_icon(slot)

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, 1, 1, 0)

/mob/proc/swap_hand()
	hand = !hand
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()

/mob/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.
	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != hand)
		swap_hand()