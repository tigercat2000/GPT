/atom/proc/attackby(obj/item/W, mob/user, params)
	return

/atom/movable/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)

/mob/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(I) && ismob(user))
		I.attack(src, user)

/obj/item/proc/attack_self(mob/user)
	return

/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

/obj/item/proc/attack(mob/M, mob/user)
	return 1