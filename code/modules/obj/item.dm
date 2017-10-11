/obj/item
	icon = 'icons/obj/items/items.dmi'
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.

/obj/item/proc/dropped(mob/user as mob)
	return 0

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0)
	if(!M)
		return 0

	return M.can_equip(src, slot, disable_warning)


// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	return

/obj/item/attack_hand(mob/user)
	if(!istype(user))
		return 0

	if(loc == user)
		if(!user.unEquip(src))
			return 0

	pickup(user)
	user.put_in_active_hand(src)