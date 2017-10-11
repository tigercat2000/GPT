/datum/hud/basic/New(mob/owner)
	. = ..()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/speed()
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "store"
	inv_box.icon_state = "store"
	inv_box.screen_loc = ui_store
	inv_box.slot_id = slot_store
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "r_hand"
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "l_hand"
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

	using = new /obj/screen/drop()
	static_inventory += using

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()