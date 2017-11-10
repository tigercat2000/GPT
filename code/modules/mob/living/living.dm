/mob/living
	icon_state = "shadow"

/mob/living/Initialize()
	remove_overlay(HAIR_LAYER)
	overlays_standing[HAIR_LAYER] = mutable_appearance('icons/mob/mob_accessories.dmi', "hair_longest_s", HAIR_LAYER)
	apply_overlay(HAIR_LAYER)

	var/obj/item/clothing/uniform/chameleon/C = new
	equip_to_slot_or_del(C, slot_w_uniform)

	var/obj/item/clothing/shoes/black/B = new
	equip_to_slot_or_del(B, slot_w_shoes)