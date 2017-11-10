/mob/living
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null

/mob/living/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state

		var/icon_file = l_hand.lefthand_file

		var/mutable_appearance/hand_overlay

		if(!hand_overlay)
			hand_overlay = l_hand.build_worn_icon(state = t_state, default_layer = L_HAND_LAYER, default_icon_file = icon_file, isinhands = TRUE)

		overlays_standing[L_HAND_LAYER] = hand_overlay

	apply_overlay(L_HAND_LAYER)

/mob/living/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state

		var/icon_file = r_hand.righthand_file

		var/mutable_appearance/hand_overlay

		if(!hand_overlay)
			hand_overlay = r_hand.build_worn_icon(state = t_state, default_layer = R_HAND_LAYER, default_icon_file = icon_file, isinhands = TRUE)

		overlays_standing[R_HAND_LAYER] = hand_overlay
	apply_overlay(R_HAND_LAYER)

/mob/living/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(istype(w_uniform, /obj/item/clothing/uniform))
		var/obj/item/clothing/uniform/U = w_uniform
		U.screen_loc = ui_w_uniform
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_uniform

		var/t_color = U.item_color
		if(!t_color)
			t_color = U.icon_state

		var/mutable_appearance/uniform_overlay

		if(!uniform_overlay)
			uniform_overlay = U.build_worn_icon(state = "[t_color]", default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/onmob/uniform.dmi', isinhands = FALSE)

		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)

/mob/living/update_inv_w_shoes()
	remove_overlay(SHOES_LAYER)

	if(istype(w_shoes, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/S = w_shoes
		S.screen_loc = ui_w_shoes
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_shoes

		var/t_color = S.item_color
		if(!t_color)
			t_color = S.icon_state

		var/mutable_appearance/uniform_overlay

		if(!uniform_overlay)
			uniform_overlay = S.build_worn_icon(state = "[t_color]", default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/onmob/feet.dmi', isinhands = FALSE)

		overlays_standing[SHOES_LAYER] = uniform_overlay

	apply_overlay(SHOES_LAYER)


/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
 inhands and any other form of worn item
 centering large appearances
 layering appearances on custom layers
 building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var
*/
/obj/item/proc/build_worn_icon(var/state = "", var/default_layer = 0, var/default_icon_file = null, var/isinhands = FALSE)

	//Find a valid icon file from variables+arguments
	var/file2use
	if(!isinhands && alternate_worn_icon)
		file2use = alternate_worn_icon
	if(!file2use)
		file2use = default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use
	if(alternate_worn_layer)
		layer2use = alternate_worn_layer
	if(!layer2use)
		layer2use = default_layer

	var/mutable_appearance/standing
	if(!standing)
		standing = mutable_appearance(file2use, state, layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands, file2use)
	if(worn_overlays && worn_overlays.len)
		standing.overlays.Add(worn_overlays)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	standing.alpha = alpha
	standing.color = color

	return standing

//Overlays for the worn overlay so you can overlay while you overlay
//eg: ammo counters, primed grenade flashing, etc.
//"icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
/obj/item/proc/worn_overlays(isinhands = FALSE, icon_file)
	. = list()