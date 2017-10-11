/mob/Login()
	client.images = null
	client.screen = list()

	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

	if(!loc)
		if(starting_pos.len)
			var/list/prefered_starting_pos = list()
			for(var/turf/pos in starting_pos)
				if(pos.Enter(src)) //this could be fucky for turfs that override Enter, but I trust the map makers
					prefered_starting_pos += pos
			if(prefered_starting_pos.len)
				forceMove(pick(prefered_starting_pos)) //prioritize unoccupied turfs over occupied turfs
			else
				forceMove(pick(starting_pos)) //but don't just leave them hanging if not

		callHook("clientNewLogin", list(src))

	player_list |= src

	. = ..()


/hook/clientNewLogin/proc/_controls_readout(mob/M)
	if(istype(M))
		to_chat(M, "<span class='notice'>Basic controls:")
		sleep(3)
		to_chat(M, "<span class='notice'>\
		      &nbsp;F12 will hide your HUD.<br>\
		      &nbsp;WASD controls movement.<br>\
		      &nbsp;Use T to say something.<br>\
		      &nbsp;Hitting TAB will switch focus between the map and input bar.<br>\
		      &nbsp;Holding Ctrl and clicking on something will pull it. Ctrl-clicking it again will release it.<br>\
		      &nbsp;Most object interactions are handled via clicking.</span>")

		return 1
	return 0