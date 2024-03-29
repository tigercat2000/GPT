/datum/hud/basic/New(mob/owner)
	. = ..()
	owner.overlay_fullscreen("see_through_darkness", /obj/screen/fullscreen/see_through_darkness)

	var/obj/screen/using

	using = new /obj/screen/speed()
	static_inventory += using

	for(var/datum/inventory_slot/S in owner.get_inv_datums())
		static_inventory += S.generate_inventory_object()

	using = new /obj/screen/drop()
	static_inventory += using

	using = new /obj/screen/throw()
	static_inventory += using
	throw_button = using

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()