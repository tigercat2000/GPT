var/const
	INV_L_HAND = "l_hand"
	INV_R_HAND = "r_hand"
	INV_STORE = "store"

	INV_W_UNIFORM = "w_uniform"
	INV_W_SHOES = "w_shoes"

/datum/inventory_slot
	var/name
	var/slot_id
	var/opposite_slot_id
	var/require_slot_flag = TRUE

	var/is_hand = FALSE // Does this get dropped with other hand items?

	// HUD
	var/hud_type = /obj/screen/inventory // Type of screen object to use for the HUD
	var/hud_position = null   // Screen_loc position on the HUD
	var/hud_icon_state = null // Icon state used for the HUD icon
	var/hud_minimized = FALSE // Is this inventory slot showed in the minimized HUD?

	// Living Icons
	var/overlay_layer = null
	var/overlay_default_icon = null

	var/tmp/obj/item/contained = null

/datum/inventory_slot/proc/generate_inventory_object()
	var/obj/screen/inventory/I = new hud_type()
	I.name = name
	I.slot_id = slot_id
	I.screen_loc = hud_position
	I.icon_state = hud_icon_state
	return I

/datum/inventory_slot/proc/get_overlay()
	if(!contained)
		return null
	var/t_color
	if(istype(contained, /obj/item/clothing))
		var/obj/item/clothing/C = contained
		t_color = C.item_color
	else
		t_color = contained.icon_state

	return contained.build_worn_icon(state = "[t_color]", default_layer = overlay_layer, default_icon_file = overlay_default_icon, isinhands = FALSE)

/datum/inventory_slot/l_hand
	name = "Left Hand"
	slot_id = INV_L_HAND
	opposite_slot_id = INV_R_HAND
	require_slot_flag = FALSE

	is_hand = TRUE

	hud_type = /obj/screen/inventory/hand
	hud_position = ui_lhand
	hud_icon_state = "hand_l"
	hud_minimized = TRUE

	overlay_layer = L_HAND_LAYER

/datum/inventory_slot/l_hand/get_overlay()
	if(!contained)
		return null

	var/t_state = contained.item_state
	if(!t_state)
		t_state = contained.icon_state

	return contained.build_worn_icon(state = t_state, default_layer = overlay_layer, default_icon_file = contained.lefthand_file, isinhands = TRUE)

/datum/inventory_slot/r_hand
	name = "Right Hand"
	slot_id = INV_R_HAND
	opposite_slot_id = INV_L_HAND
	require_slot_flag = FALSE

	is_hand = TRUE
	hud_minimized = TRUE

	hud_type = /obj/screen/inventory/hand
	hud_position = ui_rhand
	hud_icon_state = "hand_r"

	overlay_layer = R_HAND_LAYER

/datum/inventory_slot/r_hand/get_overlay()
	if(!contained)
		return null

	var/t_state = contained.item_state
	if(!t_state)
		t_state = contained.icon_state

	return contained.build_worn_icon(state = t_state, default_layer = overlay_layer, default_icon_file = contained.righthand_file, isinhands = TRUE)

/datum/inventory_slot/store
	name = "Store"
	slot_id = INV_STORE

	hud_type = /obj/screen/inventory
	hud_position = ui_store
	hud_icon_state = "store"

/datum/inventory_slot/wear_uniform
	name = "Uniform"
	slot_id = INV_W_UNIFORM

	hud_type = /obj/screen/inventory
	hud_position = ui_w_uniform
	hud_icon_state = "w_uniform"

	overlay_layer = UNIFORM_LAYER
	overlay_default_icon = 'icons/mob/onmob/uniform.dmi'

/datum/inventory_slot/wear_shoes
	name = "Shoes"
	slot_id = INV_W_SHOES

	hud_type = /obj/screen/inventory
	hud_position = ui_w_shoes
	hud_icon_state = "w_shoes"

	overlay_layer = SHOES_LAYER
	overlay_default_icon = 'icons/mob/onmob/feet.dmi'

/mob/proc/initialize_inventory()
	if(inventory.len > 0)
		return
	for(var/typepath in subtypesof(/datum/inventory_slot))
		var/datum/inventory_slot/S = new typepath()
		inventory += S
		inventory_assoc[S.slot_id] = S

/mob/Initialize()
	initialize_inventory()
	. = ..()

/mob
	var/list/inventory = list()
	var/list/inventory_assoc = list()

	var/active_hand_slot = INV_L_HAND

/mob/proc/get_slot_datum(slot)
	if(inventory_assoc[slot])
		return inventory_assoc[slot]
	CRASH("Inventory slot [slot] did not exist on mob!")
	return null

/mob/proc/get_slot_datum_by_item(obj/item/I)
	for(var/datum/inventory_slot/S in inventory)
		if(S.contained == I)
			return S
	return null

/mob/proc/get_slot_by_item(obj/item/I)
	for(var/datum/inventory_slot/S in inventory)
		if(S.contained == I)
			return S.slot_id
	return null

/mob/proc/get_slot(slot)
	var/datum/inventory_slot/S = get_slot_datum(slot)
	if(S)
		return S.contained

/mob/proc/get_inv()
	. = list()
	for(var/datum/inventory_slot/S in inventory)
		. += S.contained

/mob/proc/get_inv_datums()
	initialize_inventory() // in single-user mode the HUD loads before Initialize, so we need this to make sure it's initialized before that (it's safe)
	. = list()
	for(var/datum/inventory_slot/S in inventory)
		. += S

/mob/proc/__update_hand_hud()
	if(!hud_used)
		return
	for(var/obj/screen/inventory/hand/H in hud_used.static_inventory)
		H.update_icon()

/mob/proc/change_active_hand(optional_slot)
	if(optional_slot)
		active_hand_slot = optional_slot
		__update_hand_hud()
		return TRUE

	var/datum/inventory_slot/S = get_slot_datum(active_hand_slot)
	active_hand_slot = S.opposite_slot_id
	__update_hand_hud()
	return TRUE

/mob/proc/can_equip(datum/inventory_slot/S, obj/item/I)
	if(S.contained)
		return FALSE
	if(S.require_slot_flag && !(S.slot_id in I.slot_list))
		return FALSE
	return TRUE

// Helpers
/mob/proc/get_active_hand()
	return get_slot(active_hand_slot)

/mob/proc/get_inactive_hand()
	var/datum/inventory_slot/S = get_slot_datum(active_hand_slot)
	if(S)
		return get_slot(S.opposite_slot_id)

/mob/proc/put_in_active_hand(obj/item/I)
	equip_to_slot(I, active_hand_slot)

/mob/proc/drop_hand()
	var/datum/inventory_slot/S = get_slot_datum(active_hand_slot)
	return unEquip(S.contained)

/mob/proc/drop_hands()
	for(var/datum/inventory_slot/S in inventory)
		if(S.is_hand)
			unEquip(S.contained)

// Equip/Unequip
/mob/proc/attack_ui(slot)
	var/obj/item/I = get_active_hand()

	if(istype(I))
		equip_to_slot(I, slot)
	else
		I = get_slot(slot)
		if(I)
			I.attack_hand(src)

/mob/proc/__equip_item(datum/inventory_slot/S, obj/item/I)
	var/datum/inventory_slot/current_slot = get_slot_datum_by_item(I)
	if(current_slot)
		current_slot.contained = null

	I.screen_loc = null
	I.forceMove(src)
	I.equipped(src, S.slot_id)
	I.layer = LAYER_HUD + 1
	I.plane = PLANE_HUD
	if(pulling == I)
		stop_pulling()

	S.contained = I
	update_slot(S.slot_id)
	if(current_slot)
		update_slot(current_slot.slot_id)

/mob/proc/equip_to_slot(obj/item/I, slot, disable_warning = 0)
	var/datum/inventory_slot/S = get_slot_datum(slot)
	if(!S)
		return

	if(can_equip(S, I))
		__equip_item(S, I)
	else
		if(!disable_warning)
			to_chat(src, "<span class='warning'>You are unable to equip that.</span>")

/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return TRUE
	if((I.flags_1 & NODROP_f1) && !force)
		return FALSE
	return TRUE

/mob/proc/unEquip(obj/item/I, force)
	if(!canUnEquip(I, force))
		return FALSE

	var/datum/inventory_slot/S = get_slot_datum_by_item(I)
	S.contained = null

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(loc)
		I.dropped(src)
		if(I) // dropped() might delete the item
			I.layer = initial(I.layer)
			I.plane = initial(I.plane)

	update_slot(S.slot_id)
	return TRUE