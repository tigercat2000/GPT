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

/mob/living/update_slot(slot)
	var/datum/inventory_slot/S = ..()
	if(S && S.overlay_layer)
		remove_overlay(S.overlay_layer)
		var/mutable_appearance/slot_overlay = S.get_overlay()
		if(slot_overlay)
			overlays_standing[S.overlay_layer] = slot_overlay
		apply_overlay(S.overlay_layer)

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

/mob/living/proc/get_standard_pixel_y_offset(lying)
	if(lying)
		return -6
	else
		return initial(pixel_y)

/mob/living/var/lying_prev = 0
/mob/living/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev)
		changed++
		ntransform.TurnTo(lying_prev,lying)

		if(lying == 0) //Lying to standing
			final_pixel_y = get_standard_pixel_y_offset()
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

		lying_prev = lying	//so we don't try to animate until there's been another change.

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)
