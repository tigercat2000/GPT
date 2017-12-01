/obj/item/lighter
	name = "lighter"
	icon_state = "blackzippo"
	light_color = LIGHT_COLOR_ORANGE
	slot_list = list(INV_STORE)


/obj/item/lighter/attack_self(mob/user)
	if(icon_state == "blackzippo")
		set_light(5)
		icon_state = "blackzippoon"
	else
		set_light(0)
		icon_state = "blackzippo"