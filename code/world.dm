/world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 6		// show up to 6 tiles outward from center (13x13 view)

/world/New()
	. = ..()
	processScheduler = new
	world.log << "## processScheduler started"
	spawn(1)
		processScheduler.setup()
		processScheduler.start()