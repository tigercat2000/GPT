/mob/Login()
	client.images = null
	client.screen = list()

	if(hud_used)
		qdel(hud_used)
		hud_used = null
	hud_used = new /datum/hud(src)

	if(!loc)
		if(starting_pos.len)
			var/list/prefered_starting_pos = list()
			for(var/turf/pos in starting_pos)
				if(pos.Enter(src)) //this could be fucky for turfs that override Enter, but I trust the map makers
					prefered_starting_pos += pos
			if(prefered_starting_pos.len)
				loc = pick(prefered_starting_pos) //prioritize unoccupied turfs over occupied turfs
			else
				loc = pick(starting_pos) //but don't just leave them hanging if not
			__on_map_start()

	. = ..()