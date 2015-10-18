/obj/item/debugger
	name = "THE DEBUGGER"
	icon_state = "bike_horn"

/obj/item/debugger/attack_self(mob/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/debugger/afterattack(atom/target, mob/user, prox)
	if(!prox && istype(target)) //ranged click
		playsound(target, 'sound/items/bikehorn.ogg', 50, 1)