/area
	luminosity           = TRUE
	var/dynamic_lighting = TRUE

/area/New()
	. = ..()

	if (dynamic_lighting)
		luminosity = FALSE

/area/proc/set_dynamic_lighting(var/new_dynamic_lighting = TRUE)
	if (new_dynamic_lighting == dynamic_lighting)
		return FALSE

	dynamic_lighting = new_dynamic_lighting

	if(IS_DYNAMIC_LIGHTING(src))
		cut_overlay(/obj/effect/fullbright)
		for (var/turf/T in turfs)
			if (IS_DYNAMIC_LIGHTING(T))
				T.lighting_build_overlay()
	else
		add_overlay(/obj/effect/fullbright)
		for(var/turf/T in turfs)
			if (T.lighting_object)
				T.lighting_clear_overlay()

	return TRUE


/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("dynamic_lighting")
			set_dynamic_lighting(var_value)
			return TRUE
	return ..()