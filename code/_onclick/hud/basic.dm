/datum/hud/basic/New(mob/owner)
	. = ..()

	var/obj/screen/using

	using = new /obj/screen/speed()
	static_inventory += using

	for(var/datum/inventory_slot/S in owner.get_inv_datums())
		static_inventory += S.generate_inventory_object()

	using = new /obj/screen/drop()
	static_inventory += using

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()