#define STAGE_SOURCES  1
#define STAGE_CORNERS  2
#define STAGE_OVERLAYS 3

var/list/lighting_update_lights    = list() // List of lighting sources  queued for update.
var/list/lighting_update_corners   = list() // List of lighting corners  queued for update.
var/list/lighting_update_overlays  = list() // List of lighting overlays queued for update.


SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 1
	init_order = INIT_ORDER_LIGHTING
	priority = SS_PRIORITY_LIGHTING
	flags = SS_TICKER

	var/list/currentrun_lights
	var/list/currentrun_corners
	var/list/currentrun_overlays

	var/initialized = FALSE
	var/resuming_stage = 0

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[lighting_update_lights.len]|C:[lighting_update_corners.len]|O:[lighting_update_overlays.len]")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		create_all_lighting_overlays()
		initialized = TRUE

	..()

/datum/controller/subsystem/lighting/fire(resumed=FALSE)
	if (resuming_stage == 0 || !resumed)
		currentrun_lights   = lighting_update_lights
		lighting_update_lights   = list()

		resuming_stage = STAGE_SOURCES

	while (currentrun_lights.len)
		var/datum/light_source/L = currentrun_lights[currentrun_lights.len]
		currentrun_lights.len--

		if (L.check() || L.destroyed || L.force_update)
			L.remove_lum()
			if (!L.destroyed)
				L.apply_lum()

		else if (L.vis_update) //We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update   = FALSE
		L.force_update = FALSE
		L.needs_update = FALSE

		if (MC_TICK_CHECK)
			return

	if (resuming_stage == STAGE_SOURCES || !resumed)
		// PJB left this in, was causing crashes.
		//if (currentrun_corners && currentrun_corners.len)
		//	to_chat(world, "we still have corners to do, but we're gonna override them?")

		currentrun_corners  = lighting_update_corners
		lighting_update_corners  = list()

		resuming_stage = STAGE_CORNERS

	while (currentrun_corners.len)
		var/datum/lighting_corner/C = currentrun_corners[currentrun_corners.len]
		currentrun_corners.len--

		C.update_overlays()
		C.needs_update = FALSE
		if (MC_TICK_CHECK)
			return

	if (resuming_stage == STAGE_CORNERS || !resumed)
		currentrun_overlays = lighting_update_overlays
		lighting_update_overlays = list()

		resuming_stage = STAGE_OVERLAYS

	while (currentrun_overlays.len)
		var/atom/movable/lighting_overlay/O = currentrun_overlays[currentrun_overlays.len]
		currentrun_overlays.len--

		O.update_overlay()
		O.needs_update = FALSE
		if (MC_TICK_CHECK)
			return

	resuming_stage = 0


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
