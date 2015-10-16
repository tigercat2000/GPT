/turf/proc/get_lumcount() //Gets the lighting level of a given turf.
	if(lighting_overlay)
		return lighting_overlay.get_clamped_lum()
	return 1