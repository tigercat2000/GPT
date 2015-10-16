/mob/Stat()
	. = ..()
	if(statpanel("Processes"))
		processScheduler.statProcesses()