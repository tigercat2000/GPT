/mob/proc/__on_map_start()
	#if defined(MAP_HAS_INTRO)
	__MAP_MOB_INTRO(src)
	#endif
	return 1