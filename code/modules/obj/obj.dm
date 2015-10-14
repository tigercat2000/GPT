/obj
	icon = 'icons/obj/obj.dmi'

/obj/structure
	name = "structure"

/obj/structure/rack
	name = "rack"
	icon_state = "rack"

/obj/structure/rack/attack_hand(mob/user)
	world << "[user] attacked me halp"