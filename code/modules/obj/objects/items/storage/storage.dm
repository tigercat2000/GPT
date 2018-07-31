/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slot_list = list(INV_W_BACKPACK)
	var/component_type = /datum/component/storage/concrete

/obj/item/storage/Initialize()
	. = ..()
	PopulateContents()

/obj/item/storage/ComponentInitialize()
	AddComponent(component_type)

/obj/item/storage/AllowDrop()
	return TRUE

// Use this to fill storage items.
/obj/item/storage/proc/PopulateContents()

/* Subtypes */
/obj/item/storage/bag
	icon_state = "clownpack"

/obj/item/storage/bag/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21
