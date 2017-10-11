/proc/error(msg)
	world.log << "## ERROR: [msg]"

/proc/warning(var/text)
	world.log << "## WARNING: [text]"

/proc/log_debug(msg)
	to_chat(world, "Debug: [msg]")

/proc/message_admins(msg)
	to_chat(world, "Admin: [msg]")
