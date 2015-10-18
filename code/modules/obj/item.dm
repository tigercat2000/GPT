/obj/item
	icon = 'icons/obj/items/items.dmi'

/obj/item/proc/dropped(mob/user as mob)
	return 0

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

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
	user.Equip(src)