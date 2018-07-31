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

/mob/proc/can_interact_with(atom/A)
	return Adjacent(A)

/mob/proc/throw_mode_off()
	in_throw_mode = FALSE
	if(hud_used && hud_used.throw_button)
		hud_used.throw_button.update_icon(src)

/mob/proc/throw_mode_on()
	in_throw_mode = TRUE
	if(hud_used && hud_used.throw_button)
		hud_used.throw_button.update_icon(src)

/mob/proc/throw_item(atom/target)
	if(!target || !isturf(loc) || istype(target, /obj/screen))
		return

	var/obj/item/I = get_active_hand()

	if(!I || I.override_throw(src, target) || (I.item_flags & NODROP))
		throw_mode_off()
		return

	throw_mode_off()
	var/atom/movable/thrown_thing
	if(TRUE) //!(I.item_flags & ABSTRACT))
		thrown_thing = I
		if(!unEquip(I))
			to_chat(src, "<span class='danger'>[I] is stuck to your hand!</span>")
			return
	__throw(target, thrown_thing)

/mob/proc/__throw(atom/target, atom/movable/thrown_thing)
	if(thrown_thing)
		visible_message("<span class='danger'>[src] has thrown [thrown_thing].</span>")
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src)