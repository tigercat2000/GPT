/mob/living
	icon_state = "shadow"
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER

/mob/living/Initialize()
	..()
	remove_overlay(HAIR_LAYER)
	overlays_standing[HAIR_LAYER] = mutable_appearance('icons/mob/mob_accessories.dmi', "hair_longest_s", HAIR_LAYER)
	apply_overlay(HAIR_LAYER)

	var/obj/item/clothing/uniform/chameleon/C = new
	equip_to_slot(C, INV_W_UNIFORM, disable_warning = TRUE)

	var/obj/item/clothing/shoes/black/B = new
	equip_to_slot(B, INV_W_SHOES, disable_warning = TRUE)