/obj/item
	icon = 'icons/obj/items/items.dmi'
	var/slot_list = list() // Used to determine what slots this can go into.

	var/item_state = null
	var/lefthand_file = 'icons/mob/onmob/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/onmob/items_righthand.dmi'

	//Dimensions of the icon file used when this item is worn, eg: hats.dmi
	//eg: 32x32 sprite, 64x64 sprite, etc.
	//allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_x_dimension = 32
	var/worn_y_dimension = 32
	//Same as above but for inhands, uses the lefthand_ and righthand_ file vars
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	var/icon/alternate_worn_icon = null//If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events
	var/alternate_worn_layer = null//If this is set, update_icons() will force the on mob state (WORN, NOT INHANDS) onto this layer, instead of it's default

	var/w_class = WEIGHT_CLASS_NORMAL
	var/item_flags = NONE

	var/list/actions //list of /datum/action's that this item has.
	var/list/actions_types //list of paths of action datums to give to the item on New().

/obj/item/Initialize()
	. = ..()
	for(var/path in actions_types)
		new path(src)
	actions_types = null

/obj/item/Destroy()
	if(ismob(loc))
		var/mob/M = loc
		if(M.get_slot_by_item(src) != null)
			M.unEquip(src, force = 1)
	for(var/X in actions)
		qdel(X)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/proc/dropped(mob/user as mob)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(item_flags & DROPDEL)
		qdel(src)
	item_flags &= ~IN_INVENTORY
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)
	return 0

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	item_flags |= IN_INVENTORY
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	return

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(slot, mob/user)
	return TRUE

/obj/item/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(anchored)
		return

	// Storage components
	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)

	/*if(throwing)
		throwing.finalize(FALSE)*/

	if(loc == user)
		if(!user.unEquip(src))
			return 0

	pickup(user)
	if(!user.put_in_active_hand(src))
		dropped(user)

/obj/item/proc/remove_item_from_storage(atom/newLoc)
	if(!newLoc)
		return FALSE
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE))
		return SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, newLoc, TRUE)
	return FALSE

//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, stunned, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)