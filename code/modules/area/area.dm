/area/var/list/ambientsounds = list()

/area
	icon = 'icons/turfs/areas.dmi'
	icon_state = ""
	layer = AREA_LAYER
	mouse_opacity = 0

	var/has_gravity = TRUE

/area/proc/has_gravity()
	return has_gravity

/area/New()
	icon_state = ""

/area/Entered(A)
	. = ..()

	if(ismob(A) && prob(35) && ambientsounds.len)
		var/mob/M = A
		var/sound = pick(ambientsounds)

		if(M.client && !M.client.ambience_played)
			M.client.ambience_played = 1
			M << sound(sound, repeat = 0, wait = 0, volume = 25, channel = 1)
			spawn(600) //This is absolutely trash
				if(M && M.client)
					M.client.ambience_played = 0