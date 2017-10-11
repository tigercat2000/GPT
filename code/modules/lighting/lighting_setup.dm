/var/lighting_corners_initialised = FALSE

/proc/create_all_lighting_overlays()
	for (var/zlevel = 1 to world.maxz)
		create_lighting_overlays_zlevel(zlevel)

/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for (var/turf/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
		if (!T.dynamic_lighting)
			continue

		var/area/A = T.loc
		if (!A.dynamic_lighting)
			continue

		new /atom/movable/lighting_overlay(T)

/proc/create_all_lighting_corners()
	for (var/zlevel = 1 to world.maxz)
		create_lighting_corners_zlevel(zlevel)

	global.lighting_corners_initialised = TRUE

/proc/create_lighting_corners_zlevel(var/zlevel)
	for(var/turf/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
		T.lighting_corners_initialised = TRUE
		for (var/i = 1 to 4)
			if (!T.corners)
				T.corners = list(null, null, null, null)

			if (T.corners[i]) // Already have a corner on this direction.
				continue

			T.corners[i] = new/datum/lighting_corner(T, LIGHTING_CORNER_DIAGONAL[i])
