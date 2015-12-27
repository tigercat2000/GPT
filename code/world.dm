/world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 5		// show up to 5 tiles outward from center (11x11 view)

/world/New()
	. = ..()

	callHook("startup")

	processScheduler = new
	world.log << "## processScheduler started"
	spawn(1)
		processScheduler.setup()
		processScheduler.start()