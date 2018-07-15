/mob/New()
	. = ..()

	GLOB.mob_list |= src
	callHook("mobNew", list(src))

/mob/Destroy()
	GLOB.mob_list -= src
	return QDEL_HINT_HARDDEL_NOW

/mob/proc/ghostize()
	if(!ckey)
		return
	var/mob/ghost/G = new(loc, src)
	G.ckey = ckey
	G.name = name + " (ghost)"

	var/mutable_appearance/our_appearance = new(src)
	our_appearance.alpha = 127
	our_appearance.plane = GAME_PLANE
	G.appearance = our_appearance

/mob/proc/update_sight()
	sync_lighting_plane_alpha()

/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(L)
			L.alpha = lighting_alpha

/mob/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if("lighting_alpha")
			sync_lighting_plane_alpha()