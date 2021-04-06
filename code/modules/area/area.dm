/area/var/list/ambientsounds = list()

/area
	icon = 'icons/turfs/areas.dmi'
	icon_state = ""
	layer = AREA_LAYER
	mouse_opacity = 0

	var/has_gravity = TRUE
	///This datum, if set, allows terrain generation behavior to be ran on Initialize()
	var/datum/map_generator/map_generator
	/// For space, the asteroid, lavaland, etc. Used with blueprints or with weather to determine if we are adding a new area (vs editing a station room)
	var/outdoors = FALSE

	/// Size of the area in open turfs, only calculated for indoors areas.
	var/areasize = 0


/area/proc/has_gravity()
	return has_gravity

/area/New()
	icon_state = ""
	GLOB.areas_by_type[type] = src
	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

/**
 * Destroy an area and clean it up
 *
 * Removes the area from GLOB.areas_by_type and also stops it processing on SSobj
 *
 * This is despite the fact that no code appears to put it on SSobj, but
 * who am I to argue with old coders
 */
/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	GLOB.sortedAreas -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

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
				
/area/proc/RunGeneration()
	if(map_generator)
		map_generator = new map_generator()
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs)

/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!length(contents))
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	update_areasize()
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src

/**
 * Set the area size of the area
 *
 * This is the number of open turfs in the area contents, or FALSE if the outdoors var is set
 *
 */
/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	// FIXME: turf/open
	// for(var/turf/open/T in contents)
	// 	areasize++
